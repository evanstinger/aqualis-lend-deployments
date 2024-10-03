# Load environment variables from .env file
ifneq (,$(wildcard ./.env))
    include .env
    export
endif

# Network-specific variables
ETH_CHAINID := 1
SEPOLIA_CHAINID := 11155111
ARBITRUM_SEPOLIA_CHAINID := 421614

# Debugging: Print ETH_FROM
$(info ETH_FROM is set to: [${ETH_FROM}])

# Check for required environment variables
ifndef ETH_FROM
$(error ETH_FROM is not set. Please set it to the address you want to deploy from)
endif

# Common options
COMMON_OPTS := --sender ${ETH_FROM} --private-key ${PRIVATE_KEY} --broadcast --verify
COMMON_ARBITRUM_SEPOLIA_OPTS := --rpc-url ${ARBITRUM_SEPOLIA_RPC_URL} --etherscan-api-key ${API_KEY_ARBISCAN} --verifier-url ${ARBISCAN_SEPOLIA_URL}

# Mainnet deployments
deploy: check-eth-rpc
deploy: export FOUNDRY_ROOT_CHAINID = ${ETH_CHAINID}
deploy:
	forge script script/DeploySpark.s.sol:DeploySpark --rpc-url ${ETH_RPC_URL} ${COMMON_OPTS}

deploy-sce: check-eth-rpc
deploy-sce: export FOUNDRY_ROOT_CHAINID = ${ETH_CHAINID}
deploy-sce:
	forge script script/DeploySparkConfigEngine.s.sol:DeploySparkConfigEngine --optimizer-runs 200 --rpc-url ${ETH_RPC_URL} ${COMMON_OPTS}

deploy-pool: check-eth-rpc
deploy-pool: export FOUNDRY_ROOT_CHAINID = ${ETH_CHAINID}
deploy-pool:
	forge script script/DeployPoolImplementation.s.sol:DeployPoolImplementation --rpc-url ${ETH_RPC_URL} ${COMMON_OPTS}

# Sepolia deployments
sepolia-deploy: check-sepolia-rpc
sepolia-deploy: export FOUNDRY_ROOT_CHAINID = ${SEPOLIA_CHAINID}
sepolia-deploy:
	forge script script/DeploySpark.s.sol:DeploySpark --rpc-url ${SEPOLIA_RPC_URL} ${COMMON_OPTS}

sepolia-deploy-sce: check-sepolia-rpc
sepolia-deploy-sce: export FOUNDRY_ROOT_CHAINID = ${SEPOLIA_CHAINID}
sepolia-deploy-sce:
	forge script script/DeploySparkConfigEngine.s.sol:DeploySparkConfigEngine --optimizer-runs 200 --rpc-url ${SEPOLIA_RPC_URL} ${COMMON_OPTS}

# Arbitrum Sepolia deployments
arbitrum-sepolia-deploy: check-arbitrum-sepolia-rpc
arbitrum-sepolia-deploy: export FOUNDRY_ROOT_CHAINID = ${ARBITRUM_SEPOLIA_CHAINID}
arbitrum-sepolia-deploy:
	forge script script/DeploySpark.s.sol:DeploySpark ${COMMON_ARBITRUM_SEPOLIA_OPTS} ${COMMON_OPTS}

arbitrum-sepolia-deploy-sce: check-arbitrum-sepolia-rpc
arbitrum-sepolia-deploy-sce: export FOUNDRY_ROOT_CHAINID = ${ARBITRUM_SEPOLIA_CHAINID}
arbitrum-sepolia-deploy-sce:
	forge script script/DeploySparkConfigEngine.s.sol:DeploySparkConfigEngine --optimizer-runs 200 ${COMMON_ARBITRUM_SEPOLIA_OPTS} ${COMMON_OPTS}

# Add assets to Spark fork
add-assets: check-eth-rpc
add-assets: export FOUNDRY_ROOT_CHAINID = ${ETH_CHAINID}
add-assets:
	forge script script/AddAssets.s.sol:AddAssets --rpc-url ${ETH_RPC_URL} ${COMMON_OPTS}

sepolia-add-assets: check-sepolia-rpc
sepolia-add-assets: export FOUNDRY_ROOT_CHAINID = ${SEPOLIA_CHAINID}
sepolia-add-assets:
	forge script script/AddAssets.s.sol:AddAssets --rpc-url ${SEPOLIA_RPC_URL} ${COMMON_OPTS}

arbitrum-sepolia-add-assets: check-arbitrum-sepolia-rpc
arbitrum-sepolia-add-assets: export FOUNDRY_ROOT_CHAINID = ${ARBITRUM_SEPOLIA_CHAINID}
arbitrum-sepolia-add-assets:
	forge script script/AddAssets.s.sol:AddAssets ${COMMON_ARBITRUM_SEPOLIA_OPTS} ${COMMON_OPTS}

# Check for ETH_RPC_URL
check-eth-rpc:
ifndef ETH_RPC_URL
	$(error ETH_RPC_URL is not set. Please set it to your Ethereum mainnet RPC URL)
endif

# Check for SEPOLIA_RPC_URL
check-sepolia-rpc:
ifndef SEPOLIA_RPC_URL
	$(error SEPOLIA_RPC_URL is not set. Please set it to your Sepolia testnet RPC URL)
endif

# Check for SEPOLIA_RPC_URL
check-arbitrum-sepolia-rpc:
ifndef ARBITRUM_SEPOLIA_RPC_URL
	$(error ARBITRUM_SEPOLIA_RPC_URL is not set. Please set it to your Sepolia testnet RPC URL)
endif