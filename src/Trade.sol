// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import { TransferHelper } from "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";

contract Trade is Ownable {

    error Trade__TradeIsPaused();
    error Trade__InvalidSender();
    
    address private s_owner; // initial owner
    bool private s_tradePaused = false;
    uint256 private s_poolFee = 3000; // 0.3%
    uint256 private s_protocolFee = 2000; // 0.2%
    
    AggregatorV3Interface private s_priceFeed;
    ISwapRouter private immutable i_swapRouter; // uniswap router v3

    // ---------------------------------------- EVENTS ---------------------------------------
    event TradePaused(address indexed admin);

    constructor(address router_, address owner_, address priceFeed_) Ownable(owner_) {
        s_owner = owner_;
        s_priceFeed = AggregatorV3Interface(priceFeed_);
        i_swapRouter = ISwapRouter(router_);
    }


 // ---------------------------------------- MODIFIERS ---------------------------------------
    modifier InvalidCaller() {
        if(_msgSender() == address(0)) revert Trade__InvalidSender();
        _;
    }

    /**
        @dev only owner that can pause the trade
     */
    function pauseTrade() external onlyOwner InvalidCaller {
        bool isTradePaused = s_tradePaused;
        if(isTradePaused == false) revert Trade__TradeIsPaused();
        s_tradePaused = true;
        emit TradePaused(owner());
    }


    function tradePayNative(uint256 amount, address token, uint256 minOutAmount) external payable InvalidCaller {

    }

    function tradePayToken(address tokenIn, address tokenOut, uint256 amountIn) external InvalidCaller {
        uint256 poolFee = s_poolFee;

        // transfer token into this contract, caller must approve this txs
        TransferHelper.safeTransferFrom(tokenIn, msg.sender, address(this), amountIn);
        // approving swap_router to pull the token from this contract
        TransferHelper.safeApprove(tokenIn, address(i_swapRouter), amountIn);

        ISwapRouter.ExactInputSingleParams memory params =
            ISwapRouter.ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: _msgSender(),
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        // The call to `exactInputSingle` executes the swap.
        amountOut = i_swapRouter.exactInputSingle(params);
    }

    receive() external payable {}
}
