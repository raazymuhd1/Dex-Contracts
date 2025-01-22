// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { IQuoter } from "@uniswap/v3-periphery/contracts/interfaces/IQuoter.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract BaseSwap {
    error BaseSwap_InvalidCaller(address caller);
    error BaseSwap_NotEnoughAmt(uint256 amount);
    error BaseSwap_InvalidRecipient(address rec);
    error BaseSwap_AmountLessThanExpected(uint256 amt, uint256 expectedAmt);
    error BaseSwap_InvalidPair(address tokenA, address hopToken, address tokenB);
    // using TransferHelper libs from uniswap for safe transfering
    using TransferHelper for address;

    ISwapRouter private s_swapRouter;
    IQuoter private s_quoter;

     // ------------------------------------------------------- EVENTS ------------------------------------------
     event ExactInputSwapped(address indexed recipient, address indexed tokenIn, address indexed tokenOut);
     event ExactOutputSwapped(address indexed recipient, address indexed tokenIn, address indexed tokenOut);

    constructor(address router_, address quoter_) {
        s_swapRouter = ISwapRouter(router_);
        s_quoter = IQuoter(quoter_);
    }

    // ------------------------------------------------------- STRUCTS ------------------------------------------

    struct ParamExactInput {
        address tokenIn;
        address tokenOut;
        address hopToken;
        uint24 swapFee;
        address recipient;
        uint256 deadline;
        uint256 amountIn;
        uint256 amountOutMin;
    }

    struct ParamExactOutput {
        address tokenIn;
        address tokenOut;
        address hopToken;
        uint24 swapFee;
        address recipient;
        uint256 deadline;
        uint256 amountOut;
        uint256 amountInMax;
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

    modifier InvalidPair(address tokenA, address hopToken, address tokenB) {
        if(tokenA == address(0) || tokenB == address(0)) revert BaseSwap_InvalidPair(tokenA, hopToken, tokenB);
        _;
    } 

    /**
      @dev calling exactInput function for single or multi-hop swap
      @param params - see @ParamExactInput struct
      @return amtOut - an amount of tokenOut received by user 
     */
    function exactInputSwap(ParamExactInput memory params) internal 
       ValidCaller 
       InvalidPair(params.tokenIn, params.hopToken, params.tokenOut) 
       InvalidRecipient(params.recipient) returns(uint256 amtOut) {
        bytes memory path = abi.encodePacked(params.tokenIn, params.swapFee, params.hopToken, params.swapFee, params.tokenOut);
        if(params.amountIn <= 0) revert BaseSwap_NotEnoughAmt(params.amountIn);
        params.tokenIn.safeTransferFrom(msg.sender, address(this), params.amountIn);
        params.tokenIn.safeApprove(address(s_swapRouter), params.amountIn);

        uint256 outAmt = s_quoter.quoteExactInput(path, params.amountIn);
        ISwapRouter.ExactInputParams memory swapParams = ISwapRouter.ExactInputParams({
            path: path,
            recipient: params.recipient,
            deadline: params.deadline,
            amountIn: params.amountIn,
            amountOutMinimum: outAmt
        });

        amtOut = s_swapRouter.exactInput(swapParams);

        if(amtOut < outAmt) revert BaseSwap_AmountLessThanExpected(amtOut, outAmt);
        emit ExactInputSwapped(params.recipient, params.tokenIn, params.tokenOut);
    }

     /**
      @dev calling exactOutput function for single or multi-hop swap
      @param params - see @ParamExactOutput struct
      @return inAmount - a max amount of tokenIn user needs to pay 
     */
    function exactOutputSwap(ParamExactOutput memory params) internal 
       ValidCaller 
       InvalidPair(params.tokenIn, params.hopToken, params.tokenOut) 
       InvalidRecipient(params.recipient) returns(uint256 inAmount) {
        // path in reverse order for exactOutput
        bytes memory path = abi.encodePacked(params.tokenOut, params.swapFee, params.hopToken, params.swapFee, params.tokenIn);

        uint256 maxInAmount = s_quoter.quoteExactOutput(path, params.amountOut);
        params.tokenIn.safeTransferFrom(msg.sender, address(this), maxInAmount);
        params.tokenIn.safeApprove(address(s_swapRouter), maxInAmount);

        ISwapRouter.ExactOutputParams memory swapParams = ISwapRouter.ExactOutputParams({
            path: path,
            recipient: params.recipient,
            deadline: params.deadline,
            amountOut: params.amountOut,
            amountInMaximum: maxInAmount
        });

        inAmount = s_swapRouter.exactOutput(swapParams);
        if(inAmount < maxInAmount) {
            // if the amountIn is less than maxAmountIn require by router, then approve router to spend 0, and refund the amountIn to user
            params.tokenIn.safeApprove(address(s_swapRouter), 0);
            params.tokenIn.safeTransferFrom(address(this), params.recipient, maxInAmount - inAmount);
        }
        emit ExactInputSwapped(params.recipient, params.tokenIn, params.tokenOut);
    }


    function updateSwapConfig(address newRouter_, address newQuoter_) internal returns(address, address) {
          s_swapRouter = ISwapRouter(newRouter_);
          s_quoter = IQuoter(newQuoter_);

         return (newRouter_, newQuoter_);
    }
   
}