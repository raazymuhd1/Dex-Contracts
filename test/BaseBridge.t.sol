// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BridgeX } from "../src/BridgeX.sol";
import { BridgeXBase } from "../src/Base/BridgeXBase.sol";
import { Test, console } from "forge-std/Test.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract BaseBridge is Test {
    

    BridgeX bridgeX;

    address USER = 0x36FDBe7005414fA1611330Dc7E18725eD4A75600;
    address wormholeBridge_ = 0x3ee18B2214AFF97000D974cf647E7C347E8fa585; // mainnet
    address USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    // wormhole chain ids
    uint16 MAINNET = 2;
    uint16 ARB = 23;


    function setUp() public {
        bridgeX = new BridgeX(wormholeBridge_);
        console.log(address(bridgeX));
    }

    function test_transferTokenToChain() public {
        uint256 amount = 10e6;

        BridgeX.ParamsTransfer memory params = BridgeX.ParamsTransfer(
            USDT,
            amount,
            ARB,
            USER
        );

        vm.startPrank(USER);
        IERC20(USDT).approve(address(bridgeX), amount);
        try bridgeX.depositToChain{value: 0, gas: 1000_000}(params) {
             console.log("successfull");
        } catch (bytes memory err) {
            console.logBytes(err);
        }

        vm.stopPrank();

        // console.log("txId", txId);

    }

}