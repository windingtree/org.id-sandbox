# ORG.ID Private Ethereum Testnet

Start developing your [ORG.ID](https://orgid.tech) applications in two easy-ish steps.

## Install

### 1. Install Docker

[Docker](https://docs.docker.com/) is the only dependency. Neat!

### 2. Run the testnet

```shell
docker run -it windingtree/org.id-testnet -v orgid_volume:/org.id-testnet
```

## Connect

Hopefully, at this point you'll see a screen with all sorts of information about the testnet. Now you should are able to use the testnet via all the usual ways you would employ with your garden-variety local `go-ethereum` node. Don't worry, no need to [duckduckgo](https://duckduckgo.com/) it, we're good people, so we're going to lay it all out for you:

### 1. JavaScript Console

```shell
$
```

### 2. Execute JavaScript files

```shell
$
```

### 3. JSON-RPC

For this one you'll need to [install](https://geth.ethereum.org/docs/install-and-build/installing-geth) `go-ethereum` on your machine. See you in thirty minutes or so. Are you done? Come on, the testnet is not going connect to itself:

```shell
$
```

If you're feeling adventurous, you may do [other things, too](https://geth.ethereum.org/docs/interface/command-line-options). Go ahead, give it a spin, you've nothing to lose!

## Use

As you may have noticed, the testnet is [already populated](#whats-included) with test accounts, organizations, and such, so you can start doing things like:

### Reading organization data

```shell
$
```

### Updating organization data

```shell
$
```

### Create new organizations

```shell
$
```

## Reset testnet state

By default, the testnet's state is stored in the "orgid_testnet_volume" Docker volume. Resetting it is duck soup:

```shell
$
```

## What's Included

### Accounts

Testnet is run with 20 unlocked accounts, each with **200 ETH** and **10,000 LIF**. All smart contracts are deployed by `0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0`. All the keys are in [/keystore/](keystore) directory, along with the `password` file, which is empty, but required for account unlocking.

The keys were generated by [All Private Keys](https://allprivatekeys.com/mnemonic-code-converter) with `m/44'/1'/0'/0/0` derivation.

`inner connect add sign service load act permit episode motion image win`

- 0x28D9F2192F8CeC7724c6C71e3048D03372F8d5D0
- 0x5aafeD2ea1ca9EA4d80664b3260126058B46Da20
- 0xc5e2c01C8FdB4B090aaB30c81BeaB0BC230D0F82
- 0x5a4D34eCD771DA77996a600F1Cd9Ec720ece643e
- 0x41BF14dEB94C32FF85FD588672A75a559690C783
- 0x35B547C0d8CaE443D7aD7310CcE16755baB9cF22
- 0xb0460F188FCDE04269401c755978f78Cd44e474F
- 0x4b6Aa7b3Aec71cE0922056AD19d60414655a5642
- 0x06f2b88ed6E64B95Fe7d20948Db2c4109cDD5e89
- 0xB86cc04D6dBd61E4e9E872D129C8F51f1afEDE63

`say vague rain cause summer outside hint solar hope behave chief assist`

- 0xE45020B420144307A86C33e1C35377EAE81AB471
- 0x37A376EA0823AdbD6Ee0B82f02856d1742734226
- 0xb6Be0C762d4464cF51A48EbEA2D0da8c832Da459
- 0xC815A089883b7B0b8821CdC4EE91eB8DC45def61
- 0x27Beec4FA99F73d3eE659C38F9a2F89b1bf43d6B
- 0xeb83D7c63d4224790A635d9e198CFBbD6F63D9C5
- 0x9EFF1F1c235B20037EA8318a4b14Bf1d5F1F92d0
- 0xa6e96AC2C446F89699479FBb1bf0DE93719E2105
- 0x57416D88bf105A955e39b615a693A42F77b3e570
- 0x0CfF2c6E3D5e5a8A977089D5C0f5AC71Ca6dF67B

### Smart contracts

#### ORG.ID
#### ORG.ID Directory Index
#### ORG.ID Directories
#### Organizations

### Organizations

### Directories

## Build Container

Dependencies:

- Node: v10.19.0
- geth v1.9.13
- solc v0.6.6

```shell
./build.sh
```
