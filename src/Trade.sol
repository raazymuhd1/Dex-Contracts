// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";
import { AggregatorV3Interface } from "@chainlink/contracts/v0.8/shared/interfaces/AggregatorV3Interface.sol";

contract Trade is Ownable {

    error Trade__TradeIsPaused();
    error Trade__InvalidSender();
    
    address private s_owner; // initial owner
    bool private s_tradePaused = false;
    uint256 private s_tradeFeePercentage = 2; // 0.02%
    // 0x694AA1769357215DE4FAC081bf1f309aDC325306 price feeds sepolia
    AggregatorV3Interface private s_priceFeed;

    // ---------------------------------------- EVENTS ---------------------------------------
    event TradePaused(address indexed admin);

    constructor(address router_, address owner_, address priceFeed_) Ownable(owner_) {
        s_owner = owner_;
        s_priceFeed = AggregatorV3Interface(priceFeed_);
    }


 // ---------------------------------------- MODIFIERS ---------------------------------------
    modifier InvalidCaller() {
        if(_msgSender() == address(0)) revert Trade__InvalidSender();
        _;
    }

    function pauseTrade() external onlyOwner InvalidCaller {
        bool isTradePaused = s_tradePaused;
        if(isTradePaused == false) revert Trade__TradeIsPaused();
        s_tradePaused = true;
        emit TradePaused(owner());
    }

    function tradePayNative(uint256 amount, address token, uint256 minOutAmount) external payable InvalidCaller {

    }

    function tradePayToken() external InvalidCaller {}

    receive() external payable {}
}
