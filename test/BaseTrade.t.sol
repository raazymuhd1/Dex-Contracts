// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Test, console } from "forge-std/Test.sol";
import { YoloTrade } from "../../src/YoloTrade.sol";
import { IUniswapV3Factory } from "@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol";
import { IQuoterV2 } from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { DeployTrade } from "../script/DeployTrade.sol";
import { HelperConfig } from "../script/HelperConfig.s.sol";

contract BaseTradeTest is Test {

    YoloTrade trade;
    DeployTrade deployer;
    HelperConfig networkConfig;
    IQuoterV2 quoter_v2;
    IUniswapV3Factory poolFactory;

    address quoter;
    address router;
    address pool_factory;
    uint24 POOL_FEE = 3000;
    address USDT;
    address USDC;
    address WETH;
    address WBTC;
    address PEPE;
    address DAI;
    address USER;

    function setUp() public {
        deployer = new DeployTrade();
        networkConfig = deployer.run();
        (quoter, router, pool_factory, USER, WETH, USDT, USDC, DAI) = networkConfig.s_networkConfig();
        trade = new YoloTrade(router, quoter);
        poolFactory = IUniswapV3Factory(pool_factory);
        quoter_v2 = IQuoterV2(quoter);

        uint256 userBal = IERC20(USDT).balanceOf(USER);
        console.log("balance of ", USDT, USER);
    }

}