// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { IWormholeBridge } from "../interfaces/IWormholeBridge.sol";
import { IERC20 } from "@openzeppelin/contracts/token/ERC20/IERC20.sol";

abstract contract BridgeXBase {

    IWormholeBridge s_tokenBridge;
    uint256 private constant ARBITER_FEE = 5000 wei;
    uint32 private s_txNonce;

    // 0xDB5492265f6038831E89f495670FF909aDe94bd9 tokenBridge contract on sepolia
    constructor(address tokenBridgeAddr_) {
        s_tokenBridge = IWormholeBridge(tokenBridgeAddr_);
    } 

    // --------------------------------------------- EVENTS --------------------------------------------------------
    event TokenBridged(uint256 amount, address token, uint256 recipientChain, bytes32 recipient);

    // ---------------------------------------------- STRUCTS --------------------------------------------------------
    struct TokenTransfer {
        address token;
        uint256 amount;
        uint16 recipientChain;
        address recipient;
        uint256 arbiterFee;
        uint32 nonce;
    }

    struct TransferParams {
        address token;
        uint256 amount;
        uint16 recipientChain;
        address recipient;
    }

    /**
     * token - The address of the token being transferred.
     * amount - The amount to transfer
     * recipientChain - The Wormhole chain ID of the destination chain.
     * recipient - The recipient's address on the destination chain.
     * arbiterFee  - Optional fee to be paid to an arbiter for relaying the transfer.
     * nonce  - A unique identifier for the transaction.
     */
    function _deliverTokens(TransferParams memory tokenParams) internal returns(bool, uint64) {

        if(tokenParams.amount == 0) revert("Value must be more than zero");
        if(msg.sender == address(0)) revert("Invalid caller");

        bytes32 recipient_ = keccak256(abi.encodePacked(tokenParams.recipient));
        s_txNonce += 1;
        uint32 nonce_ = s_txNonce;

        IERC20(tokenParams.token).transferFrom(msg.sender, address(this), tokenParams.amount);
        IERC20(tokenParams.token).approve(address(s_tokenBridge), tokenParams.amount);

        // transfer token from source to destination chain.
        uint64 txId = s_tokenBridge.transferTokens(
            tokenParams.token,
            tokenParams.amount,
            tokenParams.recipientChain,
            recipient_,
            ARBITER_FEE,
            nonce_
        );

        // need a check here if a transfer went successfully or not

        emit TokenBridged(tokenParams.amount, tokenParams.token, tokenParams.recipientChain, recipient_);
        return (true, txId);
    }
}