// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { Trade } from "../../src/Trade.sol";

contract TradeTest is Test {

    Trade trade;

    function setUp() public {

    }

    function testSlippageCalculations() public {
         uint256 slippageTol = (100e18 * (100 - 6)) / 100; 

        console.log(slippageTol);
        // 94000_000_000_000_000_000
        // 94000_000_000_000_000_000
    }
}