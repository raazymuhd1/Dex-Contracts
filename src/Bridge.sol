// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {BaseTokenBridge} from "./base/BaseTokenBridge.sol";

contract Bridge is BaseTokenBridge {
    constructor(address l1GatewayRouter_, address l2GatewayRouter_)
        BaseTokenBridge(l1GatewayRouter_, l2GatewayRouter_)
    {}

    function erc20BridgeL2(address token, uint256 amount, uint256 gasLimit, address to)
        external
        payable
        returns (bool, uint256)
    {
        bridgeERC20ToL2(token, amount, gasLimit, to);
    }

    function erc20BridgeToL1(address token, uint256 amount, uint256 gasLimit, address to)
        external
        payable
        returns (bool, uint256)
    {
        bridgeERC20ToL1(token, amount, gasLimit, to);
    }

    receive() external payable {}
}
