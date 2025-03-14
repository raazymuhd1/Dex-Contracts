// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { IWormholeBridge } from "../interfaces/IWormholeBridge.sol";

contract BridgeXBase {

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
        bytes32 recipient;
        uint256 arbiterFee;
        uint32 nonce;
    }

    struct TransferParams {
        address token;
        uint256 amount;
        uint16 recipientChain;
        bytes32 recipient;
    }

    /**
     * token - The address of the token being transferred.
     * amount - The amount to transfer
     * recipientChain - The Wormhole chain ID of the destination chain.
     * recipient - The recipient's address on the destination chain.
     * arbiterFee  - Optional fee to be paid to an arbiter for relaying the transfer.
     * nonce  - A unique identifier for the transaction.
     */
    function deliverTokens(TransferParams memory tokenParams) internal returns(bool, uint64) {

        s_txNonce += 1;
        uint32 nonce_ = s_txNonce;

        TokenTransfer memory tfParams = TokenTransfer(
            tokenParams.token,
            tokenParams.amount,
            tokenParams.recipientChain,
            tokenParams.recipient,
            ARBITER_FEE,
            nonce_
        );

        uint64 txId = s_tokenBridge.transferTokens(tfParams);
    }
}