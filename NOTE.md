## Precomputed contract address
 - [create-2](https://www.cyfrin.io/glossary/precompute-contract-address-with-create2-solidity-code-example)


### How Does It Work Internally?
User Deposits Token on Source Chain

    - The user sends a token to the bridge contract on Chain A.
    - The bridge contract locks the token (or burns it in some cases).
    - An event is emitted with details of the transaction.
    - Validators or Oracles Verify the Transaction

    - The bridge contract relies on validators, oracles, or relayers to monitor events on Chain A.
    - Once the deposit is confirmed, they submit proof to the bridge contract on Chain B.
    - Tokens are Minted or Released on Destination Chain

Based on the proof from validators, the bridge contract on Chain B either:
    - Mints a new wrapped token (if using a mint-and-burn model).
    - Releases pre-existing liquidity (if using a liquidity pool model).

Reverse Process for Withdrawals
    - When transferring back, the bridge contract on Chain B will burn the wrapped token or lock liquidity.
    - Validators confirm it, and the user gets the original token back on Chain A.

### Do You Need Liquidity on Both Chains?
It depends on the type of bridge:

1️⃣ `Liquidity-Based Bridge` (AMM Model)
Yes, liquidity needs to be provided on both chains.
The bridge uses a liquidity pool to allow instant swaps.
Example: Synapse, Stargate Finance.
2️⃣ `Lock & Mint` (Wrapped Token Model)
No, you don’t need liquidity in the traditional sense.
The original token is locked on Chain A, and an equivalent wrapped token is minted on Chain B.
Example: Wrapped BTC (WBTC), Polygon PoS Bridge.
3️⃣ `Burn & Mint` (Burn Model)
No liquidity is needed since tokens are burned on one chain and minted on the other.
Example: Axelar, Wormhole (for some assets).

### Security Considerations
`Centralization Risks`: If validators are centralized, they can be hacked.
`Smart Contract Vulnerabilities`: Bridges are frequent targets of attacks (e.g., Ronin, Wormhole hacks).
`Finality Issues`: Different chains have different consensus mechanisms and finality times.