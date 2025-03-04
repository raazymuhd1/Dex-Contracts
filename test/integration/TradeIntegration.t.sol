// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BaseTradeTest } from "../BaseTrade.t.sol";
import { console } from "forge-std/Test.sol";
import { YoloTrade } from "../../src/YoloTrade.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeIntegrationTest is BaseTradeTest {

    function test_quotingExactInput() public {
         bytes memory path = abi.encodePacked(USDC, POOL_FEE, DAI);

        vm.startPrank(USER);
        // IERC20(USDC).approve(address(quoter_v2), 100e6);
       ( uint256 amountOut, , ,) = quoter_v2.quoteExactInput(path, 100e6);

       console.log("amount", amountOut);
    }

    function QuotingExactOutput(address tokenIn, address tokenOut, uint256 amountOut) public returns(uint256) {
        bytes memory path = abi.encodePacked(tokenOut, POOL_FEE, tokenIn);
        (uint256 amountInMax, , , ) = quoter_v2.quoteExactOutput(path, amountOut);

       return amountInMax;
    }

     function test_exactInputSwap() public {
        uint256 amountIn = 100e6;
        uint24 slippage = 5; 
        // swapping from USDT is not working for some reason
        vm.startPrank(USER);
        YoloTrade.SwapExactInputParams memory params = YoloTrade.SwapExactInputParams(USDC, WBTC, amountIn, slippage);
        // approving contract
        IERC20(USDC).approve(address(trade), amountIn);
        trade.swapExactInput(params);
        vm.stopPrank();

        console.log("swapped");
    }

     function test_exactOutputSwap() public {
        uint256 outAmt = 3e3;
        uint24 slippageTol = 2;

        vm.startPrank(USER);
        YoloTrade.SwapExactOutputParams memory params = YoloTrade.SwapExactOutputParams(
            USDC,
            WBTC,
            outAmt,
            slippageTol
        );
        // IERC20(USDC).approve(address(trade), );
        uint256 inAmt = trade.swapExactOutput(params);
        vm.stopPrank();

        console.log("amountIN", inAmt);
    }
    

}