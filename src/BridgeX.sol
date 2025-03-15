// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.20;

import { BridgeXBase } from "./Base/BridgeXBase.sol";
 
contract BridgeX is BridgeXBase {

    constructor(address wormholeBridge_) BridgeXBase(wormholeBridge_) {

    }
    // ---------------------------------------------- STRUCTS --------------------------------------------------------

    struct ParamsTransfer {
        address token;
        uint256 amount;
        uint16 recipientChain;
        address recipient;
    }

    function depositToChain(ParamsTransfer memory params) external payable returns(bool, uint64) {

        BridgeXBase.TransferParams memory tfParams = BridgeXBase.TransferParams(
            params.token,
            params.amount,
            params.recipientChain,
            params.recipient
        );

        (bool success, uint64 txId) = _deliverTokens(tfParams);

        if(!success) return(false, 0);
        return(success, txId);
    }

}