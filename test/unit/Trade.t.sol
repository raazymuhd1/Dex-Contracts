// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseTradeTest} from "../BaseTrade.t.sol";
import { BaseSwap as Base } from "../../src/base/BaseSwap.sol";
import {console} from "forge-std/Test.sol";
import {YoloTrade} from "../../src/YoloTrade.sol";
import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { BaseSwapError } from "../../src/errors/BaseSwapErrors.sol";

contract TradeTest is BaseTradeTest {

    function test_quotingSwap() public {
        bytes memory path = abi.encodePacked(tokens.DAI, POOL_FEE, tokens.WETH);
        vm.prank(USER);
        (uint256 amountIn, , , ) = quoter_v2.quoteExactInput(path, 10e18);
        bytes memory sig = abi.encodeWithSignature("quoteExactInput(bytes,uint256)", path, 10e18);
        (bool success, ) = address(quoter_v2).staticcall(sig);

        console.log("exactInput:", success);
        console.log(amountIn);
    }

    function test_swapExactWithZeroAddress() public {
        uint256 amountIn = 50e6;
        uint24 slippage = 2; 

        uint256 amountOut = quotingExactInput(tokens.USDC, tokens.WETH, amountIn);
        YoloTrade.SwapExactInputParams memory params = YoloTrade.SwapExactInputParams(
            tokens.USDC,
            tokens.WETH,
            amountIn,
            amountOut,
            slippage
        );
        vm.startPrank(ZERO_ADDRESS);
        vm.expectPartialRevert(Base.BaseSwapError_InvalidCaller.selector);
        trade.swapExactInput(params);
    }

    function test_swapExactWithInvalidToken() public {
        uint256 amountIn = 50e6;
        uint24 slippage = 2; 

        // uint256 amountOut = quotingExactInput(INVALID_TOKEN1, INVALID_TOKEN2, amountIn);
        YoloTrade.SwapExactInputParams memory params = YoloTrade.SwapExactInputParams(
            INVALID_TOKEN1,
            INVALID_TOKEN2,
            amountIn,
            0,
            slippage
        );
        vm.startPrank(USER);
        vm.expectPartialRevert(Base.BaseSwapError_InvalidPair.selector);
        trade.swapExactInput(params);
    }

    function test_gettingPool() public {
        vm.prank(USER);
        address poolAddr = poolFactory.getPool(tokens.USDT, tokens.DAI, 3000);
        bytes memory sig = abi.encodeWithSignature("getPool(address,address,uint256)", tokens.DAI, tokens.WETH, 3000);
        (bool success, bytes memory data) = address(pool_factory).staticcall(sig);
        console.log("static call", success);
        console.logBytes(data);
        console.log("getting pool", poolAddr);
    }

    function test_checkBalance() public {
        uint256 userBalance = IERC20(tokens.USDT).balanceOf(USER);
        console.log("user balance", userBalance);
    }

    function testSlippageCalculations() public pure {
        uint256 slippageTol = (3e8 * (100 + 6)) / 100;

        console.log(slippageTol);
    }
}
