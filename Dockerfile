# Build Geth in a stock Go builder container
FROM golang:1.14-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

WORKDIR /

RUN wget https://github.com/ethereum/go-ethereum/archive/v1.9.13.tar.gz
RUN tar -xvzf v1.9.13.tar.gz
RUN cd go-ethereum-1.9.13 && make geth
RUN mkdir -p org.id-testnet

# Create geth datadir with config
COPY ./src/keystore /org.id-testnet/keystore
COPY ./src/password /org.id-testnet/password
COPY ./src/genesis.json /org.id-testnet/genesis.json

# Initialize testnet
RUN /go-ethereum-1.9.13/build/bin/geth \
        --datadir /org.id-testnet \
        init /org.id-testnet/genesis.json

# Pull Geth into a second stage deploy alpine container
FROM node:10-alpine as setup

WORKDIR /

# Set up blockchain
COPY --from=builder /go-ethereum-1.9.13/build/bin/geth /usr/local/bin/
COPY --from=builder /org.id-testnet/ /org.id-testnet/

RUN apk add --no-cache --virtual .build-deps alpine-sdk python git
RUN mkdir -p orgid

WORKDIR /orgid

# Setup org.id repository with dependencies 
RUN git clone https://github.com/windingtree/org.id.git .
RUN cat package.json
RUN npm ci
RUN npm link

# Copy org.id setup script
RUN mkdir -p scripts
COPY ./scripts/setup.sh scripts/setup.sh

# Copy startup script
COPY ./scripts/orgid-setup-task.json scripts/orgid-setup-task.json
COPY ./scripts/start.sh /usr/local/bin
COPY ./src/truffle.js truffle.js

# Start geth node and deployment
RUN (/usr/local/bin/start.sh &) && sleep 20 && /orgid/scripts/setup.sh && sleep 10 && killall -HUP geth

# Cleanup
RUN apk del .build-deps

# Final stage
FROM node:10-alpine

COPY --from=setup /usr/local/bin/ /usr/local/bin/
COPY --from=setup /org.id-testnet/ /org.id-testnet/
COPY --from=setup /orgid/ /orgid/

EXPOSE 8545 8546 8547 30303 30303/udp

ENTRYPOINT [ "start.sh" ]
