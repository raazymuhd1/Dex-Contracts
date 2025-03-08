// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {IL1GatewayRouter} from "@scroll/contracts/L1/gateways/IL1GatewayRouter.sol";
import {IL2GatewayRouter} from "@scroll/contracts/L2/gateways/IL2GatewayRouter.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract BaseTokenBridge {
    IL1GatewayRouter private s_gatewayRouterL1;
    IL2GatewayRouter private s_gatewayRouterL2;
    // -------------------------------- EVENTS --------------------------------

    event ERC20DepositedFromL1(address indexed token, uint256 amount, address indexed sender);
    event ERC20DepositedFromL2(address indexed token, uint256 amount, address indexed sender);

    constructor(address l1GatewayRouter, address l2GatewayRouter) {
        if (l1GatewayRouter == address(0)) revert("wrong gateway router address");
        s_gatewayRouterL1 = IL1GatewayRouter(l1GatewayRouter);
        s_gatewayRouterL2 = IL2GatewayRouter(l2GatewayRouter);
    }

    // -------------------------------- MODIFIERS --------------------------------
    modifier ValidSender() {
        if (msg.sender == address(0)) revert(" invalid sender address");
        _;
    }

    modifier OnlyIfEnoughPay() {
        if (msg.value == 0) revert("fees are not enough");
        _;
    }

    /**
     * @dev bridging an ERC20 L1/L2
     * @dev a user needs to pay the gateway router for bridging ERC20 token L1/L2
     */
    function bridgeERC20ToL2(address token, uint256 amount, uint256 gasLimit, address to)
        internal
        ValidSender
        OnlyIfEnoughPay
        returns (bool, uint256)
    {
        // pulling tokens from user
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        // sending tokens to gateway router
        IERC20(token).approve(address(s_gatewayRouterL1), amount);
        s_gatewayRouterL1.depositERC20{value: msg.value}(token, to, amount, gasLimit);

        emit ERC20DepositedFromL1(token, amount, msg.sender);
        return (true, amount);
    }

    /**
     * @dev bridging an ERC20 L2/L1
     * @dev a user needs to pay the gateway router for bridging ERC20 token L1/L2
     */
    function bridgeERC20ToL1(address token, uint256 amount, uint256 gasLimit, address to)
        internal
        ValidSender
        OnlyIfEnoughPay
        returns (bool, uint256)
    {
        IERC20(token).transferFrom(msg.sender, address(this), amount);
        // sending tokens to gateway router
        IERC20(token).approve(address(s_gatewayRouterL2), amount);
        s_gatewayRouterL2.withdrawERC20{value: msg.value}(token, to, amount, gasLimit);

        emit ERC20DepositedFromL2(token, amount, msg.sender);
        return (true, amount);
    }
}
