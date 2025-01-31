include .env

test-exact-input:; forge test --mt test_exactInputSwap --fork-url $(BASE_MAINNET_RPC) -vvvvv