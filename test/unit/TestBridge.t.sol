// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { Bridge } from "../../src/Bridge.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
// import { IScrollERC20Upgradeable } from "@scroll/contracts/libraries/token/"
import { IL1GatewayRouter } from "@scroll/contracts/L1/gateways/IL1GatewayRouter.sol";

contract BridgeTest is Test {

    Bridge bridge;
    IL1GatewayRouter l1GatewayRouter_;
    address l1GatewayRouter =  0xF8B1378579659D8F7EE5f3C929c2f3E332E41Fd6;
    address l2GatewayRouter = 0x4C0926FF5252A435FD19e10ED15e5a249Ba19d79;
    address USER = 0x3005A4C0EFE7E66F3f60eF8704983247A5c6ca61;
    address USER2 = 0x4097E255DeDc6EC11132fdE8f9081e17c6f9aeC8;
    address USDCL1 = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address USDCL2 = 0x06eFdBFf2a14a7c8E15944D1F4A48F9F95F663A4;
    uint256 constant TEST_AMOUNT = 100e6;
    uint256 constant GAS_LIMIT = 200_000;
    uint256 constant BRIDGE_FEE = 0.0001 ether;
    uint256 constant BRIDGEL2_FEE = 0.005 ether;

    string MAINNET_RPC = vm.envString("MAINNET_RPC");
    string SCROLL_MAINNET_RPC = vm.envString("SCROLL_MAINNET_RPC");
    uint256 MAINNET_FORK;
    uint256 SCROLL_FORK;

    function setUp() public {
        bridge = new Bridge(l1GatewayRouter, l2GatewayRouter);
        l1GatewayRouter_ = IL1GatewayRouter(l1GatewayRouter);
        MAINNET_FORK = vm.createFork(MAINNET_RPC);
        SCROLL_FORK = vm.createFork(SCROLL_MAINNET_RPC);

        vm.makePersistent(address(bridge));
    }

    function test_bridgeErc20FromL1() public {
        vm.selectFork(MAINNET_FORK);
        uint256 userBalanceBfore = IERC20(USDCL1).balanceOf(USER);
        console.log("prev balance", userBalanceBfore);
        vm.startPrank(USER);
        IERC20(USDCL1).approve(address(bridge), TEST_AMOUNT);
        bridge.erc20BridgeL2{value: BRIDGE_FEE}(
            USDCL1,
            TEST_AMOUNT,
            GAS_LIMIT,
            USER2
        );
        uint256 userBalanceAfter = IERC20(USDCL1).balanceOf(USER);
        console.log("prev balance", userBalanceAfter);
        // making the contract persistent when another fork is active

        // switching to scroll fork mode
        vm.selectFork(SCROLL_FORK);
        vm.startPrank(USER2);
        IERC20(USDCL2).approve(address(bridge), TEST_AMOUNT);
        bridge.erc20BridgeToL1{value: BRIDGEL2_FEE}(
            USDCL2,
            TEST_AMOUNT,
            GAS_LIMIT,
            USER
        );
        // checking user balance on scroll chian
         uint256 userBalanceL2 = IERC20(USDCL2).balanceOf(USER);
         console.log(userBalanceL2);
    }

    function test_getL2TokenAddr() public {
        address usdcL2 = l1GatewayRouter_.getL2ERC20Address(USDCL1);
        console.log(usdcL2);
    }
}