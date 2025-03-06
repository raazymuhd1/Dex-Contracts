// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import { Script, console } from "forge-std/Script.sol";

contract HelperConfig is Script {

    NetworkConfig public s_networkConfig;

    struct NetworkConfig {
        address quoterV2;
        address router;
        address poolFactory;
        address USER;
        address WETH;
        address USDT;
        address USDC;
        address DAI;
    }

    constructor() {
        if(block.chainid == 1) {
           s_networkConfig = mainnetConfig();
        } else if(block.chainid == 2) {
           s_networkConfig = baseMainnetConfig();
        }
    }

    function mainnetConfig() public returns(NetworkConfig memory) {
        NetworkConfig memory network = NetworkConfig({
            quoterV2: 0x61fFE014bA17989E743c5F6cB21bF9697530B21e,
            router: 0x68b3465833fb72A70ecDF485E0e4C7bD8665Fc45,
            poolFactory: 0x1F98431c8aD98523631AE4a59f267346ea31F984,
            USER: 0x36FDBe7005414fA1611330Dc7E18725eD4A75600,
            WETH: 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2,
            USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            DAI: 0x6B175474E89094C44Da98b954EedeAC495271d0F
        });

        return network;
    }

    function baseMainnetConfig() public returns(NetworkConfig memory) {
          NetworkConfig memory network = NetworkConfig({
            quoterV2: 0x3d4e44Eb1374240CE5F1B871ab261CD16335B76a,
            router: 0x2626664c2603336E57B271c5C0b26F421741e481,
            poolFactory: 0x33128a8fC17869897dcE68Ed026d694621f6FDfD,
            USER: 0x36FDBe7005414fA1611330Dc7E18725eD4A75600,
            WETH: 0x4200000000000000000000000000000000000006,
            USDT: 0xfde4C96c8593536E31F229EA8f37b2ADa2699bb2,
            USDC: 0x833589fCD6eDb6E08f4c7C32D4f71b54bdA02913,
            DAI: 0x50c5725949A6F0c72E6C4a641F24049A917DB0Cb
        });

         return network;
    }

    function baseSepoliaConfig() public returns(NetworkConfig memory) {
          NetworkConfig memory network = NetworkConfig({
            quoterV2: 0xC5290058841028F1614F3A6F0F5816cAd0df5E27,
            router: 0x94cC0AaC535CCDB3C01d6787D6413C739ae12bc4,
            poolFactory: 0x4752ba5DBc23f44D87826276BF6Fd6b1C372aD24,
            USER: 0x36FDBe7005414fA1611330Dc7E18725eD4A75600,
            WETH: 0x4200000000000000000000000000000000000006,
            USDT: 0xdAC17F958D2ee523a2206206994597C13D831ec7,
            USDC: 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48,
            DAI: 0x6B175474E89094C44Da98b954EedeAC495271d0F
        });

         return network;
    }

}