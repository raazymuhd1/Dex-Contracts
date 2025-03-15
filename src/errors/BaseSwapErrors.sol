// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

contract BaseSwapError {
     // errors
    error BaseSwap_InvalidCaller(address caller);
    error BaseSwap_NotEnoughAmt(uint256 amount);
    error BaseSwap_InvalidRecipient(address rec);
    error BaseSwap_AmountLessThanExpected(uint256 amt, uint256 expectedAmt);
    error BaseSwap_InvalidPair(address tokenA, address tokenB);
    error BaseSwap_SlippageExceeded(uint256 amountOut);
    error BaseSwap_PoolNotExist();
}