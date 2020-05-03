# Build Geth in a stock Go builder container
FROM golang:1.14-alpine as builder

RUN apk add --no-cache make gcc musl-dev linux-headers git

WORKDIR /

RUN wget https://github.com/ethereum/go-ethereum/archive/v1.9.13.tar.gz
RUN tar -xvzf v1.9.13.tar.gz
RUN cd go-ethereum-1.9.13 && make geth

# Pull Geth into a second stage deploy alpine container
FROM node:10-alpine

# Set up blockchain
COPY --from=builder /go-ethereum-1.9.13/build/bin/geth /usr/local/bin/

WORKDIR /

COPY testnet-datadir .

COPY scripts/start.sh /usr/local/bin
COPY scripts/orgid_testnet_console.sh /usr/local/bin

EXPOSE 8545 8546 8547 30303 30303/udp

ENTRYPOINT [ "start.sh" ]
