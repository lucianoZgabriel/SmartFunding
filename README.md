# SmartFunding Smart Contract

## Table of Contents

- [SmartFunding Smart Contract](#smartfunding-smart-contract)
  - [Table of Contents](#table-of-contents)
  - [About](#about)
  - [Interact with the Frontend](#interact-with-the-frontend)
    - [Key Features](#key-features)
  - [Technologies](#technologies)
  - [Project Structure](#project-structure)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
  - [Available Commands](#available-commands)
  - [Deployment](#deployment)
    - [Local Deployment](#local-deployment)
    - [Sepolia Deployment](#sepolia-deployment)
  - [Contract Interaction](#contract-interaction)
    - [Send Funds](#send-funds)
    - [Withdraw Funds](#withdraw-funds)
  - [Testing](#testing)
  - [License](#license)
  - [Contributing](#contributing)

## About

SmartFunding is a smart contract developed in Solidity that implements a decentralized funding system. The contract allows users to send ETH which is converted to USD using Chainlink Oracle to ensure a minimum contribution of $5 USD.

## Interact with the Frontend

You can interact with the already deployed contract on Sepolia network by visiting the [SmartFunding Frontend](https://smart-funding.vercel.app).

### Key Features

- ETH funding with USD minimum value
- Real-time price conversion via Chainlink
- Owner-controlled withdrawal system
- Multi-network support (Mainnet, Sepolia, Local)

## Technologies

- Solidity ^0.8.27
- Foundry Framework
- Chainlink Price Feeds
- Bash Scripts

## Project Structure

- `src/`: Contains the Solidity smart contract.
- `test/`: Contains the test files for the smart contract.
- `script/`: Contains the deployment and interaction scripts.
- `lib/`: Contains the external libraries used in the project.

## Prerequisites

- Foundry installed
- Node.js and npm
- Git
- Ethereum account and ETH for deployment and interactions
- Etherscan API key for contract verification

## Installation

1. Clone the repository:

```bash
git clone [REPOSITORY_URL]
cd smart-funding
```

2. Install dependencies:

```bash
./scripts.sh install
```

3. Configure environment variables:
   Create a .env file in the project root with the following variables:

```bash
SEPOLIA_RPC_URL=your_rpc_url
ACCOUNT=your_private_key
ETHERSCAN_API_KEY=your_api_key
SENDER_ADDRESS=your_ethereum_address
```

## Available Commands

The project includes an automation script (scripts.sh) with the following commands:

```bash
./scripts.sh clean - Clean the repository
./scripts.sh remove - Remove modules
./scripts.sh install - Install dependencies
./scripts.sh update - Update dependencies
./scripts.sh build - Build the project
./scripts.sh test - Run all tests
./scripts.sh snapshot - Create test snapshot
./scripts.sh format - Format code
./scripts.sh anvil - Start local Anvil node
./scripts.sh deploy - Local deployment
./scripts.sh deploy-sepolia - Deploy to Sepolia network
./scripts.sh fund - Send funds to contract
./scripts.sh withdraw - Withdraw funds from contract
```

## Deployment

### Local Deployment

```bash
./scripts.sh anvil
./scripts.sh deploy
```

### Sepolia Deployment

```bash
./scripts.sh deploy-sepolia
```

## Contract Interaction

### Send Funds

```bash
./scripts.sh fund
```

### Withdraw Funds

```bash
./scripts.sh withdraw
```

## Testing

```bash
./scripts.sh test
```

## License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.

## Contributing

We welcome contributions to improve the project. Please open an issue or submit a pull request.
