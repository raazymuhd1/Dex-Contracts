// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
    @notice A Base contract for swap functionalities, other contracts could inherits from this Base Contract
    @notice this contract uses a UniswapV3 Router contract 
 */

import { ISwapRouterV2 } from "../interfaces/ISwapRouterV2.sol";
import { IQuoterV2 } from "@uniswap/v3-periphery/contracts/interfaces/IQuoterV2.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract BaseSwap {
    // errors
    error BaseSwap_InvalidCaller(address caller);
    error BaseSwap_NotEnoughAmt(uint256 amount);
    error BaseSwap_InvalidRecipient(address rec);
    error BaseSwap_AmountLessThanExpected(uint256 amt, uint256 expectedAmt);
    error BaseSwap_InvalidPair(address tokenA, address tokenB);
    error BaseSwap_SlippageExceeded(uint256 amountOut);

    ISwapRouterV2 private s_swapRouter;
    IQuoterV2 private s_quoter;

    uint256 private constant SLIPPAGE_PERCENTAGE = 100; // 100%

     // ------------------------------------------------------- EVENTS ------------------------------------------
     event ExactInputSwapped(address indexed recipient, address indexed tokenIn, address indexed tokenOut);
     event ExactOutputSwapped(address indexed recipient, address indexed tokenIn, address indexed tokenOut);

    constructor(address router_, address quoter_) {
        s_swapRouter = ISwapRouterV2(router_);
        s_quoter = IQuoterV2(quoter_);
    }

    // ------------------------------------------------------- STRUCTS ------------------------------------------

    struct ParamExactInput {
        address tokenIn;
        address tokenOut;
        uint24 swapFee;
        address recipient;
        uint256 amountIn;
        uint24 slippageTolerance;
    }

    struct ParamExactOutput {
        address tokenIn;
        address tokenOut;
        uint24 swapFee;
        address recipient;
        uint256 amountOut;
        uint24 slippageTolerance;
    }

    // ------------------------------------------------------- MODIFIERS ------------------------------------------
    modifier ValidCaller() {
        if(msg.sender == address(0)) revert BaseSwap_InvalidCaller(msg.sender);
        _;
    }

    modifier InvalidRecipient(address rec) {
        if(rec == address(0)) revert BaseSwap_InvalidRecipient(rec);
        _;
    } 

    modifier InvalidPair(address tokenA, address tokenB) {
        if(tokenA == address(0) || tokenB == address(0)) revert BaseSwap_InvalidPair(tokenA, tokenB);
        _;
    } 

    /**
      @dev calling exactInput function for single or multi-hop swap
      @param params - see @ParamExactInput struct
      @return actualAmt - an amount of tokenOut received by user 
     */
    function exactInputSwap(ParamExactInput memory params) internal 
       ValidCaller 
       InvalidPair(params.tokenIn, params.tokenOut) 
       InvalidRecipient(params.recipient) returns(uint256 actualAmt) {
        bytes memory path = abi.encodePacked(params.tokenIn, params.swapFee, params.tokenOut);
        if(params.amountIn <= 0) revert BaseSwap_NotEnoughAmt(params.amountIn);
        TransferHelper.safeTransferFrom(params.tokenIn, msg.sender, address(this), params.amountIn);
        TransferHelper.safeApprove(params.tokenIn, address(s_swapRouter), params.amountIn);

        ( uint256 amountOut, , ,) = s_quoter.quoteExactInput(path, params.amountIn);
        ISwapRouterV2.ExactInputParams memory swapParams = ISwapRouterV2.ExactInputParams({
            path: path,
            recipient: params.recipient,
            amountIn: params.amountIn,
            amountOutMinimum: amountOut
        });

        actualAmt = s_swapRouter.exactInput(swapParams);
        // handling the slippage tolerance calculations
        // if the price when the trade gets executed is higher than the time user places a trade, revert the tx 
        // another word, if the outAmount is 1% (whetever slippage tolerance percentage user select) less than the expected OutAmount, revert the tx. 
        uint256 slippageTol = (amountOut * (SLIPPAGE_PERCENTAGE - params.slippageTolerance)) / 100; 

        if(actualAmt < slippageTol) revert("slippage tolerance exceeded");
        // if user gets less than the slippage tolerance, then revert the tx
        // if(actualAmt < expectedAmt) revert BaseSwap_SlippageExceeded(actualAmt);
        emit ExactInputSwapped(params.recipient, params.tokenIn, params.tokenOut);
    }

     /**
      @dev calling exactOutput function for single or multi-hop swap
      @param params - see @ParamExactOutput struct
      @return inAmount - a max amount of tokenIn user needs to pay 
     */
    function exactOutputSwap(ParamExactOutput memory params) internal 
       ValidCaller 
       InvalidPair(params.tokenIn, params.tokenOut) 
       InvalidRecipient(params.recipient) returns(uint256 inAmount) {
        // path in reversed order for exactOutput
        bytes memory path = abi.encodePacked(params.tokenOut, params.swapFee, params.tokenIn);
        // // quote a swap
        (uint256 maxInAmount, , ,) = s_quoter.quoteExactOutput(path, params.amountOut);
        // token transfer & approval
        TransferHelper.safeTransferFrom(params.tokenIn, msg.sender, address(this), maxInAmount);
        TransferHelper.safeApprove(params.tokenIn, address(s_swapRouter), maxInAmount);
        // swap params
        ISwapRouterV2.ExactOutputParams memory swapParams = ISwapRouterV2.ExactOutputParams({
            path: path,
            recipient: params.recipient,
            amountOut: params.amountOut,
            amountInMaximum: maxInAmount
        });
        // calling for swap
        inAmount = s_swapRouter.exactOutput(swapParams);    
        // slippage tolerance handler
        uint256 slippageTol = (maxInAmount * (SLIPPAGE_PERCENTAGE - params.slippageTolerance)) / 100;
        if(inAmount > slippageTol) revert BaseSwap_SlippageExceeded(maxInAmount);
        if(inAmount < maxInAmount) {
            // if the amountIn is less than maxAmountIn required by router, then approved the router to spend 0, and refund the amountIn to user
            TransferHelper.safeApprove(params.tokenIn, address(s_swapRouter), 0);
            TransferHelper.safeTransferFrom(params.tokenIn, address(this), params.recipient, maxInAmount - inAmount);
        }
        emit ExactOutputSwapped(params.recipient, params.tokenIn, params.tokenOut);
    }

    /**
        @dev updating the swap router, and quoter
        @notice can only be called by its child
     */
    function _updateSwapConfig(address newRouter_, address newQuoter_) internal returns(address, address) {
          s_swapRouter = ISwapRouterV2(newRouter_);
          s_quoter = IQuoterV2(newQuoter_);

         return (newRouter_, newQuoter_);
    }
   
}