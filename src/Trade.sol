// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import { ISwapRouter } from "@uniswap/v3-periphery/contracts/interfaces/ISwapRouter.sol";
import { Ownable } from "@openzeppelin/contracts/access/Ownable.sol";

contract Trade is Ownable {
    
    address private s_owner; // initial owner

    constructor(address router_, address owner_) Ownable(owner_) {
        s_owner = owner_;
    }



    function tradePayNative(uint256 amount, address token, uint256 minOutAmount) external payable {

    }

    function tradePayToken() external {}

    receive() external payable {}
}
