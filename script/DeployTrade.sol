// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";
import { HelperConfig } from "./HelperConfig.s.sol";
import { YoloTrade } from "../src/YoloTrade.sol";

contract DeployTrade is Script {

    HelperConfig helperConfig;

     address quoterV2;
     address router;
     address poolFactory;
     address USER;
     address WETH;
     address USDT;
     address USDC;
     address DAI;

    function run() public returns(HelperConfig) {
        vm.broadcast();
        helperConfig = new HelperConfig();

        return helperConfig;
    }
}
