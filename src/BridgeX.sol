// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BridgeXBase } from "./base/BridgeXBase.sol";

contract BridgeX is BridgeXBase {

    constructor(address wormholeBridge_) BridgeXBase(wormholeBridge_) {

    }

    // ---------------------------------------------- STRUCTS --------------------------------------------------------

    function depositToChain(BridgeXBase.TransferParams memory params) external payable returns(bool, uint64) {

        BridgeXBase.TransferParams memory tfParams = BridgeXBase.TransferParams(
            params.token,
            params.amount,
            params.recipientChain,
            params.recipient
        );

        _deliverTokens(tfParams);
    }

}