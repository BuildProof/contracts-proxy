# Intuition Attestor Contracts


## Overview

The **Intuition Attestor Contracts** repository contains smart contracts that serve as a **proxy attestor** within the Intuition ecosystem. These contracts enable groups of individuals to collectively attest to information or claims from a single, unified address, adding a decentralized layer of trust and credibility.

With the Intuition Attestor Contracts, groups can:
- **Act as a Collective Attestor**: Multiple individuals can attest to facts, reviews, or statements from the same address, creating a single trusted source.
- **Enhance Credibility and Trust**: By aggregating attestations from a group, these contracts add weight and legitimacy to each claim.
- **Support Decentralized Verification**: This approach allows communities, organizations, or DAOs to issue collective attestations without needing each member to use a separate address.

These proxy attestor contracts are a foundational part of the Intuition knowledge graph, enabling decentralized and collaborative attestation across various entities, thereby increasing transparency and trust within the network.


`Attestor` contract allows for the whitelisted accounts to attest on behalf of the Intuiton itself, effectively acting as an official attestor account. It follows the beacon proxy pattern, and is deployed via `AttestorFactory` contract, which itself follows the transparent upgradeable proxy pattern.

## Building and Running Tests

To build the project and run tests, follow these steps:

### Prerequisites

- [Node.js](https://nodejs.org/en/download/)
- [Foundry](https://getfoundry.sh)

### Step by Step Guide

#### Install Dependencies

```shell
$ npm i
$ forge install
```

#### Build

```shell
$ forge build
```

#### Run Tests

```shell
$ forge test -vvv
```

#### Run Fuzz Tests

- Make sure you have at least node 16 and python 3.6 installed on your local machine
- Add your FUZZ_AP_KEY to the .env file locally
- Run the following command to install the `diligence-fuzzing` package:

```shell
$ pip3 install diligence-fuzzing
```

- After the installation is completed, run the fuzzing CLI:

```shell
$ fuzz forge test
```

- Finally, check your Diligence Fuzzing dashboard to see the results of the fuzzing tests

#### Run Slither (Static Analysis)

- Install the `slither-analyzer` package:
  
```shell
  $ pip3 install slither-analyzer
```

- After the installation is completed, run the slither analysis bash script:

```shell
  $ npm run slither
```

### Deployment Process

To deploy the smart contracts on to a public testnet or mainnet, you’ll need the following:
- RPC URL of the network that you’re trying to deploy to (as for us, we’re targeting Base Sepolia testnet as our target chain for the testnet deployments)
- Export `PRIVATE_KEY` of a deployer account in the terminal, and fund it with some test ETH to be able to cover the gas fees for the smart contract deployments
- For Base Sepolia, there is a reliable [testnet faucet](https://alchemy.com/faucets/base-sepolia) deployed by Alchemy
- Deploy smart contracts using the following command:

```shell
$ forge script script/Deploy.s.sol --broadcast --rpc-url <your_rpc_url> --private-key $PRIVATE_KEY
```

### Deployment Verification

To verify the deployed smart contracts on Etherscan, you’ll need to export your Etherscan API key as `ETHERSCAN_API_KEY` in the terminal, and then run the following command:

```shell
$ forge verify-contract <0x_contract_address> ContractName --watch --chain-id <chain_id>
```

**Notes:**

- When verifying your smart contracts, you can use an optional parameter `--constructor-args` to pass the constructor arguments of the smart contract in the ABI-encoded format
- The chain ID for Base Sepolia is `84532`, whereas the chain ID for Base Mainnet is `8453`
