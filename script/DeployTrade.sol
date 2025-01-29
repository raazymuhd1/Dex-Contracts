// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import { Trade } from "../src/Trade.sol";

contract CounterScript is Script {
    function setUp() public {}

    // 0x694AA1769357215DE4FAC081bf1f309aDC325306 price feeds sepolia

    function run() public {
        vm.broadcast();
    }
}
