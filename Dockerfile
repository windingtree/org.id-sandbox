# STAGE 1
# Build Geth in a stock Go builder container
FROM golang:alpine as builder
ARG DATADIR

RUN apk add --no-cache make gcc musl-dev linux-headers git
RUN git clone https://github.com/ethereum/go-ethereum /go-ethereum
RUN cd /go-ethereum && make all

# STAGE 2
# Build a testnet
FROM alpine:latest as testnet
ARG DATADIR

RUN apk add --no-cache ca-certificates
COPY --from=builder /go-ethereum/build/bin/* /usr/local/bin/

# Create geth datadir with config
COPY ./src/geth/config/ $DATADIR/
COPY ./src/geth/scripts/init.sh $DATADIR/init.sh
COPY ./src/geth/scripts/start.sh $DATADIR/start.sh
RUN chmod +x $DATADIR/init.sh
RUN chmod +x $DATADIR/start.sh

# Initialize testnet
RUN $DATADIR/init.sh

# STAGE 3
# Populate test-network with data
FROM node:10-alpine as setup
ARG DATADIR
ARG SENDGRID_API_KEY
ARG ETHERSCAN_KEY
ARG DEFI_PULSE_KEY
ARG STRIPE_SECRET
ARG STRIPE_HOOK_SECRET
ARG STRIPE_HOOK_SECRET_TEST

# Pull artifacts from previous stages
COPY --from=builder /go-ethereum/build/bin/ /usr/local/bin/
COPY --from=testnet $DATADIR/ $DATADIR/

RUN apk add --no-cache --virtual .build-deps alpine-sdk python git jq

# Setup org.id repository with dependencies
RUN git clone https://github.com/windingtree/org.id.git /org.id
WORKDIR /org.id
RUN npm i
RUN mkdir -p /org.id/setup
COPY ./src/org.id/scripts/setup.sh /org.id/setup/setup.sh
COPY ./src/org.id/config/setup-task.json /org.id/setup/setup-task.json
COPY ./src/org.id/config/truffle.js /org.id/truffle.js
RUN chmod +x /org.id/setup/setup.sh

# Setup org.id-directories repository
RUN git clone https://github.com/windingtree/org.id-directories.git /org.id-directories
WORKDIR /org.id-directories
RUN npm i
RUN mkdir -p /org.id-directories/setup
COPY ./src/org.id-directories/scripts/  /org.id-directories/setup/
COPY ./src/org.id-directories/config/setup-task.json /org.id-directories/setup/setup-task.json
COPY ./src/org.id-directories/config/setup-directories-task.json /org.id-directories/setup/setup-directories-task.json
COPY ./src/org.id-directories/config/truffle.js /org.id-directories/truffle.js
RUN chmod +x /org.id-directories/setup/setup.sh

# # Setup payment manager repository [!!!!! skipped for now !!!!!]
# RUN git clone git@github.com:windingtree/payment-manager.git /payment-manager
# WORKDIR /payment-manager
# RUN npm ci

# Start geth node and deployment
RUN ($DATADIR/start.sh &) && \
    sleep 20 && \
    /org.id/setup/setup.sh && \
    /org.id-directories/setup/setup.sh && \
    sleep 10 && \
    killall -HUP geth

# Setup arbor-backend repository
RUN echo "arbor-backend v1.1.3" && git clone https://github.com/windingtree/arbor-backend.git /arbor-backend
WORKDIR /arbor-backend
RUN rm -rf package-lock.json && npm i
COPY ./src/arbor-backend/config/1st-party.json /arbor-backend/modules/config/lib/1st-party.json
COPY ./src/arbor-backend/config/3rd-party.json /arbor-backend/modules/config/lib/3rd-party.json
COPY ./src/arbor-backend/config/config_aggregator.json /arbor-backend/modules/config/lib/config_aggregator.json
COPY ./src/arbor-backend/config/config.json /arbor-backend/modules/config/lib/config.json
COPY ./src/arbor-backend/scripts/start-arbor.sh /arbor-backend/start-arbor.sh
RUN chmod +x /arbor-backend/start-arbor.sh

# Setup MySQL DB
RUN apk add --update mysql mysql-client
COPY ./src/arbor-backend/scripts/setup.sh /var/lib/mysql/setup.sh
COPY ./src/arbor-backend/scripts/start-mysql.sh /var/lib/mysql/start-mysql.sh
COPY ./src/arbor-backend/config/my.cnf /etc/mysql/my.cnf
RUN chmod +x /var/lib/mysql/setup.sh
RUN chmod +x /var/lib/mysql/start-mysql.sh

RUN /var/lib/mysql/setup.sh && \
    sleep 10 && \
    killall -HUP mysqld

# Deploy organizations
COPY ./src/org.id/data/ /org.id/setup/data/
COPY ./src/org.id/config/setup-legal-task.json /org.id/setup/setup-legal-task.json
COPY ./src/org.id/config/setup-units-task.json /org.id/setup/setup-units-task.json
COPY ./src/org.id/scripts/serve-data.sh /org.id/setup/serve-data.sh
COPY ./src/org.id/scripts/setup-organizations.sh /org.id/setup/setup-organizations.sh
RUN chmod +x /org.id/setup/serve-data.sh
RUN chmod +x /org.id/setup/setup-organizations.sh

RUN /org.id/setup/setup-organizations.sh && \
    sleep 10 && \
    killall -HUP mysqld && \
    killall -HUP node

# Cleanup
RUN apk del .build-deps && rm -f /var/cache/apk/*

# STAGE 4
# Building of a final container
FROM node:10-alpine
ARG DATADIR
ENV DATADIR=$DATADIR

RUN apk add --update --no-cache mysql mysql-client supervisor nano
COPY --from=setup /usr/local/bin/ /usr/local/bin/
COPY --from=setup $DATADIR/ $DATADIR/
# @todo Copy deployment configs only instead of whole projects folders
COPY --from=setup /org.id/ /org.id/
COPY --from=setup /org.id-directories/ /org.id-directories/
COPY --from=setup /var/lib/mysql/ /var/lib/mysql/
COPY --from=setup /run/mysqld/ /run/mysqld/
COPY --from=setup /etc/mysql/my.cnf /etc/mysql/my.cnf
COPY --from=setup /arbor-backend/ /arbor-backend/
COPY ./src/supervisor/config/supervisord.conf /etc/supervisord.conf
RUN sed -i "s/DATADIR/$(printf '%s\n' "$DATADIR" | sed -e 's/[]\/$*.^[]/\\&/g')/g" /etc/supervisord.conf

EXPOSE 8545 8546 8547 30303 30303/udp 3306 3333 4444 9001

VOLUME $DATADIR
VOLUME /var/lib/mysql

ENTRYPOINT [ "supervisord", "--configuration", "/etc/supervisord.conf" ]
