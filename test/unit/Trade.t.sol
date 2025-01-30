// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { Trade } from "../../src/Trade.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeTest is Test {

    Trade trade;

    address quoter = 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a;
    address router = 0x2626664c2603336E57B271c5C0b26F421741e481;
    address USDT = 0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2;
    address USDC = 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913;
    address USER = 0x3a92f10694f38f2bea6A3794c3bD06880572Dc1f;

    function setUp() public {
        trade = new Trade(router, quoter);
    }

    function test_exactInputSwap() public {
        uint256 amountIn = 5e6;
        uint24 slippage = 5; 

        vm.startPrank(USER);
        Trade.SwapExactInputParams memory params = Trade.SwapExactInputParams(USDT, USDC, amountIn, slippage);
        // approving contract
        IERC20(USDT).approve(address(trade), amountIn);
        trade.swapExactInput(params);
        vm.stopPrank();

        console.log("swapped");
    }

    function testSlippageCalculations() public {
         uint256 slippageTol = (100e18 * (100 - 6)) / 100; 

        console.log(slippageTol);
        // 94000_000_000_000_000_000
        // 94000_000_000_000_000_000
    }
}