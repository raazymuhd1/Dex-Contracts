// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BaseTradeTest } from "../BaseTrade.t.sol";
import { console } from "forge-std/Test.sol";
import { YoloTrade } from "../../src/YoloTrade.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { BaseSwap as Base } from "../../src/Base/BaseSwap.sol";

contract TradeIntegrationTest is BaseTradeTest {

    function quotingExactInput(address tokenIn, address tokenOut, uint256 amountIn) public returns(uint256) {
        uint256 amountIn = 100e6;
        uint256 amountOut = trade.quotingTrade(
            Base.ParamQuoteTrade(tokenIn, tokenOut, POOL_FEE, amountIn),
            0
        );

       console.log("amount", amountOut);
       return amountOut;
    }

    function quotingExactOutput(address tokenIn, address tokenOut, uint256 amountOut) public returns(uint256) {
          uint256 amountOut = 3e3;

        uint256 amountIn = trade.quotingTrade(
            Base.ParamQuoteTrade(tokenIn, tokenOut, POOL_FEE, amountOut),
            1
        );

       console.log("amount", amountIn);
       return amountIn;
    }

     function test_exactInputSwap() public {
        uint256 amountIn = 100e6;
        uint24 slippage = 2; 
        // swapping from USDT is not working for some reason
        vm.startPrank(USER);
        uint256 amountOutMin = quotingExactInput(USDC, WBTC, amountIn);
        YoloTrade.SwapExactInputParams memory params = YoloTrade.SwapExactInputParams(USDC, WBTC, amountIn, amountOutMin, slippage);
        // approving contract
        IERC20(USDC).approve(address(trade), amountIn);
        uint256 amountOut = trade.swapExactInput(params);
        vm.stopPrank();

        console.log("swapped", amountOut);
    }

     function test_exactOutputSwap() public {
        uint256 outAmt = 3e3;
        uint24 slippageTol = 2;

        vm.startPrank(USER);
        uint256 amountInMax = quotingExactOutput(USDC, WETH, outAmt);
        YoloTrade.SwapExactOutputParams memory params = YoloTrade.SwapExactOutputParams(
            USDC,
            WBTC,
            outAmt,
            amountInMax,
            slippageTol
        );
        bytes memory path = abi.encodePacked(params.tokenOut, POOL_FEE, params.tokenIn);
        // (uint256 maxInAmount, , ,) = quoter_v2.quoteExactOutput(path, outAmt);
        IERC20(USDC).approve(address(trade), amountInMax);
        uint256 inAmt = trade.swapExactOutput(params);
        vm.stopPrank();

        console.log("amountIN", inAmt);
    }
    

}