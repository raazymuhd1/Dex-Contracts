// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BaseSwap as Base } from "./Base/BaseSwap.sol";
// import { AggregatorV3Interface } from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Trade is Base, Ownable {

    error Trade__TradeIsPaused();
    error Trade__InvalidSender();
    error Trade__UnexpectedAmount();
    
    address private s_owner; // initial owner
    bool private s_tradePaused = false;
    uint256 private s_protocolFee = 2000; // 0.2%
    // constants
    uint256 private constant DECIMALS18 = 1e18;
    uint256 private constant DECIMALS6 = 1e6;
    uint24 private constant POOL_FEE = 3000; // 0.3%
    address private constant HOP_TOKEN = address(0);
    

    // ---------------------------------------- EVENTS ---------------------------------------
    event TradePaused(address indexed admin);
    event SwapSuccessfull(address tokenA, address tokenB, uint256 amount);

    constructor(address router_,  address quoter_) Base(router_, quoter_) Ownable(msg.sender) {
        s_owner = owner();
        // s_priceFeed = AggregatorV3Interface(priceFeed_);
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


 // ---------------------------------------- EXTERNAL & PUBLIC FUNCTIONS ---------------------------------------

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
        if(params.amtIn <= 0) revert Base.BaseSwap_NotEnoughAmt(params.amtIn);
         Base.ParamExactInput memory swapParams = Base.ParamExactInput(
            params.tokenIn,
            params.tokenOut,
            HOP_TOKEN,
            POOL_FEE,
            msg.sender,
            block.timestamp,
            params.amtIn,
            params.slippageTolerance
         );
        // calling for swap
        uint256 amountOut =  exactInputSwap(swapParams);
        if(amountOut <= 0) revert Trade__UnexpectedAmount();
        emit SwapSuccessfull(params.tokenIn, params.tokenOut, params.amtIn);
    }

    /**
        @dev performing a swap for an exact Output amount of tokenOut
     */
    function swapExactOutput(SwapExactOutputParams calldata params) external returns(uint256 amtOut) {
        
    }

    /**
        @dev calling for router & quoter update
        @param routerNew_ - an address of a new router
        @param quoterNew_ - an address of a new quoter
     */
     function updateConfig(address routerNew_, address quoterNew_) external onlyOwner returns(address, address) {
        _updateSwapConfig(routerNew_, quoterNew_);
     }

    receive() external payable {}
}
