// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { YoloTrade } from "../src/YoloTrade.sol";

contract CounterScript is Script {
    function setUp() public {}
    HelperConfig helperConfig;

    // 0x694AA1769357215DE4FAC081bf1f309aDC325306 price feeds sepolia

    function run() public {
        vm.broadcast();
        helperConfig = new HelperConfig();
        (address quoter, , , , , , ) = helperConfig.s_networkConfig();

        console.log(quoter);
    }
}
