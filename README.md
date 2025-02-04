# Permissionless EthMultiVault Proxy

## Overview

This repository contains a forked and modified version of the Intuition Attestor Contracts, redesigned to serve as a permissionless proxy for batch operations with EthMultiVault. The main purpose of this contract is to provide efficient batch deposit and redeem functionality for any user interacting with the EthMultiVault.

### Key Features

- **Permissionless Access**: Anyone can use the proxy contract to interact with EthMultiVault
- **Batch Operations**: Efficient handling of multiple deposits and redemptions in a single transaction
- **Gas Optimization**: Reduced transaction costs through batched operations
- **Direct User Ownership**: All operations maintain direct ownership of assets by the end user

For detailed information about the modifications and architectural changes, see our [Action Plan](./action_plan.md).

### Deployments

The contract is currently deployed on Base Sepolia at:
[0x60d7753825673a9d1942a117bfa63f7d9e16dcc4](https://sepolia.basescan.org/address/0x60d7753825673a9d1942a117bfa63f7d9e16dcc4)

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

To deploy the smart contracts on to a public testnet or mainnet, you'll need the following:

- RPC URL of the network that you're trying to deploy to (as for us, we're targeting Base Sepolia testnet as our target chain for the testnet deployments)
- Export `PRIVATE_KEY` of a deployer account in the terminal, and fund it with some test ETH to be able to cover the gas fees for the smart contract deployments
- For Base Sepolia, there is a reliable [testnet faucet](https://alchemy.com/faucets/base-sepolia) deployed by Alchemy
- Deploy smart contracts using the following command:

```shell
$ forge script script/Deploy.s.sol --broadcast --rpc-url <your_rpc_url> --private-key $PRIVATE_KEY
```

### Deployment Verification

To verify the deployed smart contracts on Etherscan, you'll need to export your Etherscan API key as `ETHERSCAN_API_KEY` in the terminal, and then run the following command:

```shell
$ forge verify-contract <0x_contract_address> ContractName --watch --chain-id <chain_id>
```

**Notes:**

- When verifying your smart contracts, you can use an optional parameter `--constructor-args` to pass the constructor arguments of the smart contract in the ABI-encoded format
- The chain ID for Base Sepolia is `84532`, whereas the chain ID for Base Mainnet is `8453`
