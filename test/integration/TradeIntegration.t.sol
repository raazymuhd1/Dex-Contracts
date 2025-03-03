// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BaseTradeTest } from "../BaseTrade.t.sol";
import { console } from "forge-std/Test.sol";
import { YoloTrade } from "../../src/YoloTrade.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeIntegrationTest is BaseTradeTest {

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
         bytes memory path = abi.encodePacked(params.tokenOut, POOL_FEE, params.tokenIn);
        (uint256 maxAmtIn, , , ) = quoter_v2.quoteExactOutput(path, outAmt);
        IERC20(USDC).approve(address(trade), maxAmtIn);
        uint256 inAmt = trade.swapExactOutput(params);
        vm.stopPrank();

        console.log("amountIN", inAmt);
    }
    

}