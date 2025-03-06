// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { BaseSwap as Base } from "./Base/BaseSwap.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/shared/interfaces/AggregatorV3Interface.sol";

contract YoloTrade is Base, Ownable {

    error Trade__TradeIsPaused();
    error Trade__InvalidSender();
    error Trade__UnexpectedAmount();
    
    address private s_owner; // initial owner
    uint256 private s_protocolFee = 2000; // 0.2%
    // trade status is active by default
    TradeStatus private s_tradeStatus = TradeStatus.Active;
    // constants
    uint256 private constant DECIMALS18 = 1e18;
    uint256 private constant DECIMALS6 = 1e6;
    uint24 private constant POOL_FEE = 3000; // 0.3%
    address private constant HOP_TOKEN = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2; // WETH
    

    // ---------------------------------------- EVENTS ---------------------------------------
    event TradePaused(address indexed admin, uint256 timestamp);
    event TradeUnPaused(address indexed admin, uint256 timestamp);
    event SwapSuccessfull(address tokenA, address tokenB, uint256 amount);

    constructor(address router_,  address quoter_) Base(router_, quoter_) Ownable(msg.sender) {
        s_owner = owner();
        // s_priceFeed = AggregatorV3Interface(priceFeed_);
    }

    // -------------------------------------- MODIFIERS --------------------------------
    modifier OnlyIfNotPaused() {
        uint256 tradeStatus = uint256(s_tradeStatus);
        if(tradeStatus == uint256(TradeStatus.Paused)) revert("trade has been paused");
        _;
    }

    // -------------------------------------- ENUMS --------------------------------
    enum TradeStatus {
        Paused,
        Active
    }

 // ---------------------------------------- STRUCTS ---------------------------------------
   struct SwapExactInputParams {
       address tokenIn;
       address tokenOut;
       uint256 amtIn;
       uint256 amtOutMin;
       uint24 slippageTolerance;
   }

   struct SwapExactOutputParams {
       address tokenIn;
       address tokenOut;
       uint256 amtOut;
       uint256 amtInMax;
       uint24 slippageTolerance;
   }


 // ---------------------------------------- EXTERNAL & PUBLIC FUNCTIONS ---------------------------------------

    /**
        @dev only owner that can pause the trade
     */
    function pauseOrUnPause() external onlyOwner ValidCaller {
        uint256 tradeStatus = uint256(s_tradeStatus);
        if(tradeStatus == uint256(TradeStatus.Active)) {
            s_tradeStatus = TradeStatus.Paused;
            emit TradePaused(owner(), block.timestamp);
            
        } else if(tradeStatus == uint256(TradeStatus.Paused)) {
            s_tradeStatus = TradeStatus.Active;
            emit TradeUnPaused(owner(), block.timestamp);
        }
    }

    /**
        @dev performing a swap for exact tokenIn for tokenOut
        @param params - see @SwapExactInputParams struct for details
     */
    function swapExactInput(SwapExactInputParams calldata params) external ValidCaller OnlyIfNotPaused returns(uint amountOut) {
        if(params.amtIn <= 0) revert Base.BaseSwap_NotEnoughAmt(params.amtIn);
         Base.ParamExactInput memory swapParams = Base.ParamExactInput(
            params.tokenIn,
            params.tokenOut,
            POOL_FEE,
            msg.sender,
            params.amtIn,
            params.amtOutMin,
            params.slippageTolerance
         );
        // calling for swap
        amountOut =  exactInputSwap(swapParams);
        if(amountOut <= 0) revert Trade__UnexpectedAmount();
        emit SwapSuccessfull(params.tokenIn, params.tokenOut, params.amtIn);
    }

    /**
        @dev performing a swap for an exact Output amount of tokenOut
     */
    function swapExactOutput(SwapExactOutputParams calldata params) external ValidCaller OnlyIfNotPaused returns(uint256 amtIn) {
        Base.ParamExactOutput memory swapParams = Base.ParamExactOutput(
            params.tokenIn,
            params.tokenOut,
            POOL_FEE,
            msg.sender,
            params.amtOut,
            params.amtInMax,
            params.slippageTolerance
        );

        amtIn = exactOutputSwap(swapParams);
    }

    /**
     * @dev getting token price for any supported tokens by chainlink price feeds oracle
     */
    function gettingTokenPrice(address token) external returns(uint256 price_) {

    }

    function _handleTokenPrice(address token) internal returns(uint256) {

    }

    receive() external payable {}
}
