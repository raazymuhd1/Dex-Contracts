// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BaseTokenBridge } from "./base/BaseTokenBridge.sol";

contract Bridge is BaseTokenBridge {
    
    constructor(address l1GatewayRouter_) BaseTokenBridge(l1GatewayRouter_) {

    }

    function erc20BridgeL1(address token, uint256 amount, uint256 gasLimit) external payable returns(bool, uint256) {
        bridgeERC20L1(
            token,
            amount,
            gasLimit
        );
    }

    receive() payable external {
    }
}