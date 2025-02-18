include .env

exact_input:; forge test --mt test_exactInputSwap --fork-url ${MAINNET_RPC} -vvvvv

bridge_erc20l1:; forge test --mt test_bridgeErc20FromL1 --fork-url MAINNET_RPC -vvvvv

