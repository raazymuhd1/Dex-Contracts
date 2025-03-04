// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { BaseTradeTest } from "../BaseTrade.t.sol";
import { console } from "forge-std/Test.sol";
import { YoloTrade } from "../../src/YoloTrade.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract TradeTest is BaseTradeTest {

    function test_quotingSwap() public {
        bytes memory pathOut = abi.encodePacked(WETH, POOL_FEE, DAI);
        bytes memory pathIn = abi.encodePacked(DAI, POOL_FEE, WETH);
        vm.prank(USER);
        // (uint256 amountIn, , , ) = quoter_v2.quoteExactOutput(pathOut, 0.01 ether);
        (uint256 amountOut, , , ) = quoter_v2.quoteExactInput(pathIn, 10e18);

        console.log("exactInput:", amountOut);
        // console.log(amountIn);
    }

    function test_gettingPool() public {
        vm.prank(USER);
        address poolAddr = poolFactory.getPool(DAI, WBTC, 3000);
        console.log("getting pool", poolAddr);
    }

    function test_checkBalance() public {
       uint256 userBalance =  IERC20(USDT).balanceOf(USER);
       console.log("user balance", userBalance);
    }

    function testSlippageCalculations() public pure{
         uint256 slippageTol = (3e8 * (100 + 6)) / 100; 

        console.log(slippageTol);
     
    }
}