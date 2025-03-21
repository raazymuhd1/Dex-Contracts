// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import {BaseTradeTest} from "../BaseTrade.t.sol";
import {console} from "forge-std/Test.sol";
import {YoloTrade} from "../../src/YoloTrade.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {BaseSwap as Base} from "../../src/Base/BaseSwap.sol";

contract TradeIntegrationTest is BaseTradeTest {

    function test_exactInputSwap() public {
        uint256 amountIn = 100e6;
        uint24 slippage = 2;
        // swapping from USDT is not working for some reason
        vm.startPrank(USER);
        uint256 amountOutMin = quotingExactInput(tokens.USDC, tokens.WETH, amountIn);
        YoloTrade.SwapExactInputParams memory params =
            YoloTrade.SwapExactInputParams(tokens.USDC, tokens.WETH, amountIn, amountOutMin, slippage);
        // approving contract
        IERC20(tokens.USDC).approve(address(trade), amountIn);
        uint256 amountOut = trade.swapExactInput(params);
        vm.stopPrank();

        console.log("swapped", amountOut);
        console.log(USER);
    }

    function test_exactOutputSwap() public {
        uint256 outAmt = 3e3;
        uint24 slippageTol = 2;

        vm.startPrank(USER);
        uint256 amountInMax = quotingExactOutput(tokens.USDC, tokens.WETH, outAmt);
        YoloTrade.SwapExactOutputParams memory params =
            YoloTrade.SwapExactOutputParams(tokens.USDC, tokens.WETH, outAmt, amountInMax, slippageTol);
        bytes memory path = abi.encodePacked(params.tokenOut, POOL_FEE, params.tokenIn);
        // (uint256 maxInAmount, , ,) = quoter_v2.quoteExactOutput(path, outAmt);
        IERC20(tokens.USDC).approve(address(trade), amountInMax);
        uint256 inAmt = trade.swapExactOutput(params);
        vm.stopPrank();

        console.log("amountIN", inAmt);
    }

    function test_pauseTrade() public {
        vm.startPrank(USER);
        trade.pauseOrUnPause();
        YoloTrade.TradeStatus tradeState = trade.getTradeStatus();
        vm.stopPrank();

        console.log("trade status", uint256(tradeState));
    }
}
