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
        uint256 amountOutMin = quotingExactInput(tokens.USDC, tokens.WETH, amountIn);
        YoloTrade.SwapExactInputParams memory params = YoloTrade.SwapExactInputParams(tokens.USDC, tokens.WETH, amountIn, amountOutMin, slippage);
        // approving contract
        IERC20(tokens.USDC).approve(address(trade), amountIn);
        uint256 amountOut = trade.swapExactInput(params);
        vm.stopPrank();

        console.log("swapped", amountOut);
    }

     function test_exactOutputSwap() public {
        uint256 outAmt = 3e3;
        uint24 slippageTol = 2;

        vm.startPrank(USER);
        uint256 amountInMax = quotingExactOutput(tokens.USDC, tokens.WETH, outAmt);
        YoloTrade.SwapExactOutputParams memory params = YoloTrade.SwapExactOutputParams(
            tokens.USDC,
            tokens.WETH,
            outAmt,
            amountInMax,
            slippageTol
        );
        bytes memory path = abi.encodePacked(params.tokenOut, POOL_FEE, params.tokenIn);
        // (uint256 maxInAmount, , ,) = quoter_v2.quoteExactOutput(path, outAmt);
        IERC20(tokens.USDC).approve(address(trade), amountInMax);
        uint256 inAmt = trade.swapExactOutput(params);
        vm.stopPrank();

        console.log("amountIN", inAmt);
    }

    // function test_gettingTokenPrice() public {
    //     address USDT_FEED = 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D;
    //     uint256 PRECISION = 1e6;
    //     uint256 testAmount = 10e6;


    //     vm.prank(USER);
    //     int256 price = trade.gettingTokenPrice(tokens.USDT, USDT_FEED);
    //     uint256 priceIn6 = uint256(price) / 1e2;
    //     uint256 priceInUsd = (testAmount * priceIn6) / PRECISION;
    //     // 99_998_783
    //     // 16_666_463_833_333
    //     console.log("base price", price);
    //     console.log("token price in USD", priceInUsd);
    // }
    

}