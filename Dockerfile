ARG DATADIR=/org.id-testnet-data

# STAGE 1
# Build Geth in a stock Go builder container
FROM golang:alpine as builder

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
FROM node:12-alpine as setup
ARG DATADIR

# Pull artifacts from previous stages
COPY --from=builder /go-ethereum/build/bin/ /usr/local/bin/
COPY --from=testnet $DATADIR/ $DATADIR/

RUN apk add --no-cache --virtual .build-deps alpine-sdk python git

# Setup org.id repository with dependencies
RUN git clone https://github.com/windingtree/org.id.git /org.id
RUN cd /org.id && npm i
RUN mkdir -p /org.id/setup
COPY ./src/org.id/scripts/setup.sh /org.id/setup/setup.sh
COPY ./src/org.id/config/setup-task.json /org.id/setup/setup-task.json
COPY ./src/org.id/config/truffle.js /org.id/truffle.js
RUN chmod +x /org.id/setup/setup.sh

# # Setup org.id-directories repository
# RUN mkdir -p /org.id-directories
# RUN git clone git@github.com:windingtree/org.id-directories.git /org.id-directories
# RUN cd /org.id-directories && npm ci

# # Setup payment manager repository
# RUN mkdir -p /payment-manager
# RUN git clone git@github.com:windingtree/payment-manager.git /payment-manager
# RUN cd /payment-manager && npm ci

# # Setup arbor-backend repository
# RUN mkdir -p /arbor-backend
# RUN git clone git@github.com:windingtree/arbor-backend.git /arbor-backend
# RUN cd /arbor-backend && npm ci

# Start geth node and deployment
RUN ($DATADIR/start.sh &) && sleep 20 && /org.id/setup/setup.sh && sleep 10 && killall -HUP geth

# Cleanup
RUN apk del .build-deps

# STAGE 4
# Building of a final container
FROM node:12-alpine
ARG DATADIR
ENV DATADIR=$DATADIR

COPY --from=setup /usr/local/bin/ /usr/local/bin/
COPY --from=setup $DATADIR/ $DATADIR/
COPY --from=setup /org.id/ /org.id/
RUN ln -s $DATADIR/start.sh /usr/local/bin/start.sh

EXPOSE 8545 8546 8547 30303 30303/udp

ENTRYPOINT [ "start.sh" ]
