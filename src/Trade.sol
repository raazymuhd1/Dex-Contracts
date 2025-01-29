// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { IQuoter } from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import { BaseSwap as Base } from "./Base/BaseSwap.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Trade is Base, Ownable {

    error Trade__TradeIsPaused();
    error Trade__InvalidSender();
    
    address private s_owner; // initial owner
    bool private s_tradePaused = false;
    uint256 private s_protocolFee = 2000; // 0.2%
    // constants
    uint256 private constant DECIMALS18 = 1e18;
    uint256 private constant DECIMALS6 = 1e6;
    uint256 private constant POOL_FEE = 3000; // 0.3%
    
    AggregatorV3Interface private s_priceFeed;


    // ---------------------------------------- EVENTS ---------------------------------------
    event TradePaused(address indexed admin);

    constructor(address router_,  address quoter_, address priceFeed_) Base(router_, quoter_) Ownable(msg.sender) {
        s_owner = owner();
        s_priceFeed = AggregatorV3Interface(priceFeed_);
    }

 // ---------------------------------------- STRUCTS ---------------------------------------
   struct SwapExactInputParams {
       address tokenIn;
       address tokenOut;
       uint256 amtIn;
       uint24 slippageTolerance;
   }

   struct SwapExactOutputParams {
       address tokenIn;
       address tokenOut;
       uint256 amtOut;
       uint24 slippageTolerance;
   }


 // ---------------------------------------- MODIFIERS ---------------------------------------

    /**
        @dev only owner that can pause the trade
     */
    function pauseTrade() external onlyOwner ValidCaller {
        bool isTradePaused = s_tradePaused;
        if(isTradePaused == false) revert Trade__TradeIsPaused();
        s_tradePaused = true;
        emit TradePaused(owner());
    }

    /**
        @dev performing a swap for exact tokenIn for tokenOut
     */
    function swapExactInput(SwapExactInputParams calldata params) external ValidCaller {
       

    }

    function swapExactOutput(SwapExactOutputParams calldata params) external returns(uint256 amtOut) {
        
    }

    receive() external payable {}
}
