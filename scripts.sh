#!/bin/bash

# Load environment variables from the .env file
set -a
source .env
set +a

# Define default variables
DEFAULT_ANVIL_KEY="0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80"
NETWORK_ARGS="--rpc-url http://localhost:8545 --private-key $DEFAULT_ANVIL_KEY --broadcast"

# Function to show available commands
show_help() {
    echo "Available commands:"
    echo "  ./scripts.sh clean         - Cleans the repository"
    echo "  ./scripts.sh remove        - Removes modules"
    echo "  ./scripts.sh install       - Installs dependencies"
    echo "  ./scripts.sh update        - Updates dependencies"
    echo "  ./scripts.sh build         - Builds the project"
    echo "  ./scripts.sh test          - Runs tests"
    echo "  ./scripts.sh snapshot      - Creates a snapshot"
    echo "  ./scripts.sh format        - Formats the code"
    echo "  ./scripts.sh anvil         - Starts Anvil"
    echo "  ./scripts.sh deploy        - Local deploy"
    echo "  ./scripts.sh deploy-sepolia - Deploy to Sepolia"
    echo "  ./scripts.sh fund          - Funds the contract"
    echo "  ./scripts.sh withdraw      - Withdraws funds"
}

# Main function to execute commands
execute_command() {
    case $1 in
        "clean")
            forge clean
            ;;
        "remove")
            rm -rf .gitmodules && rm -rf .git/modules/* && rm -rf lib && touch .gitmodules && git add . && git commit -m "modules"
            ;;
        "install")
            forge install cyfrin/foundry-devops@0.2.2 --no-commit && \
            forge install smartcontractkit/chainlink-brownie-contracts@1.1.1 --no-commit && \
            forge install foundry-rs/forge-std@v1.8.2 --no-commit
            ;;
        "update")
            forge update
            ;;
        "build")
            forge build
            ;;
        "test")
            forge test --match-path "test/**/*.sol"
            ;;
        "test-unit")
            forge test --match-path "test/unit/**/*.sol"
            ;;
        "test-integration")
            forge test --match-path "test/integration/**/*.sol"
            ;;
        "snapshot")
            forge snapshot
            ;;
        "format")
            forge fmt
            ;;
        "anvil")
            anvil -m 'test test test test test test test test test test test junk' --steps-tracing --block-time 1
            ;;
        "deploy")
            forge script script/DeploySmartFunding.s.sol:DeploySmartFunding $NETWORK_ARGS
            ;;
        "deploy-sepolia")
            NETWORK_ARGS="--rpc-url $SEPOLIA_RPC_URL --private-key $ACCOUNT --broadcast --verify --etherscan-api-key $ETHERSCAN_API_KEY -vvvv"
            forge script script/DeploySmartFunding.s.sol:DeploySmartFunding $NETWORK_ARGS
            ;;
        "fund")
            if [ -z "$SENDER_ADDRESS" ]; then
                echo "Error: SENDER_ADDRESS not defined in .env"
                exit 1
            fi
            forge script script/Interactions.s.sol:FundSmartFunding --sender $SENDER_ADDRESS $NETWORK_ARGS
            ;;
        "withdraw")
            if [ -z "$SENDER_ADDRESS" ]; then
                echo "Error: SENDER_ADDRESS not defined in .env"
                exit 1
            fi
            forge script script/Interactions.s.sol:WithdrawSmartFunding --sender $SENDER_ADDRESS $NETWORK_ARGS
            ;;
        *)
            echo "Invalid command: $1"
            show_help
            exit 1
            ;;
    esac
}

# If no command is provided, show help
if [ $# -eq 0 ]; then
    show_help
    exit 1
fi

# Execute the provided command
execute_command "$1"