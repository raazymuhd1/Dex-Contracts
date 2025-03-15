// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/IERC20Permit.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";


contract DexAggregator is ReentrancyGuard, Ownable {

    mapping(string => Dex) public dexes;

    // -------------------------------------------------------------- STRUCT ---------------------------------------------------------
    event SwapExecuted(address indexed user, string dexName, uint256 amountIn, uint256 amountOut);

    constructor(DexesDetail memory dexesDetail_) Ownable(msg.sender) {
        dexes["UniswapV3"] = Dex(dexesDetail_.uniswapRouter, dexesDetail_.uniswapQuoter, 3000); // Uniswap V2 Router
        dexes["SushiSwap"] = Dex(dexesDetail_.sushiswapRouter, dexesDetail_.sushiQuoter, 0); // SushiSwap Router
        dexes["IzumiSwap"] = Dex(dexesDetail_.izumiRouter, dexesDetail_.izumiQuoter, 3000); // Uniswap V3 Router
    }

    // -------------------------------------------------------------- STRUCT ---------------------------------------------------------
      struct Dex {
        address router;
        address quoter;
        uint24 fee; // Used for Uniswap V3
    }

    struct DexesDetail {
        address uniswapRouter;
        address sushiswapRouter;
        address izumiRouter;
        address uniswapQuoter;
        address sushiQuoter;
        address izumiQuoter;
    }


    function getBestSwapRate(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) public view returns (string memory bestDex, uint256 bestAmountOut) {
        string[3] memory dexNames = ["UniswapV2", "SushiSwap", "UniswapV3"];
        for (uint i = 0; i < dexNames.length; i++) {
            Dex memory dex = dexes[dexNames[i]];
            uint256 amountOut = _getAmountOut(tokenIn, tokenOut, amountIn, dex);
            if (amountOut > bestAmountOut) {
                bestAmountOut = amountOut;
                bestDex = dexNames[i];
            }
        }
    }

    function _getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        Dex memory dex
    ) internal view returns (uint256) {
        if (dex.router == address(0)) return 0;
        if (dex.fee == 0) { // Uniswap V2 & SushiSwap
            // address;
            // path[0] = tokenIn;
            // path[1] = tokenOut;
            // try IUniswapV2Router(dex.router).getAmountsOut(amountIn, path) returns (uint256[] memory amounts) {
            //     return amounts[1];
            // } catch {
            //     return 0;
            // }
        } else { // Uniswap V3
            // try IUniswapV3Router(dex.router).exactInputSingle(tokenIn, tokenOut, dex.fee, address(this), amountIn, 1) returns (uint256 amountOut) {
            //     return amountOut;
            // } catch {
            //     return 0;
            // }
        }
    }

    function swapTokensWithPermit(
        address tokenIn,
        address tokenOut,
        uint256 amountIn,
        uint256 minAmountOut,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external nonReentrant {
        require(amountIn > 0, "Invalid amount");

        // Use permit to approve the contract for spending the user's tokens
        IERC20Permit(tokenIn).permit(msg.sender, address(this), amountIn, deadline, v, r, s);

        (string memory bestDex, uint256 bestAmountOut) = getBestSwapRate(tokenIn, tokenOut, amountIn);
        require(bestAmountOut >= minAmountOut, "Slippage too high");

        // Transfer tokens after permit
        IERC20(tokenIn).transferFrom(msg.sender, address(this), amountIn);
        IERC20(tokenIn).approve(dexes[bestDex].router, amountIn);

        if (keccak256(bytes(bestDex)) == keccak256(bytes("UniswapV2")) || keccak256(bytes(bestDex)) == keccak256(bytes("SushiSwap"))) {
            address;
            // path[0] = tokenIn;
            // path[1] = tokenOut;
            // IUniswapV2Router(dexes[bestDex].router).swapExactTokensForTokens(amountIn, minAmountOut, path, msg.sender, block.timestamp);
        } else {
            // IUniswapV3Router(dexes[bestDex].router).exactInputSingle(tokenIn, tokenOut, dexes[bestDex].fee, msg.sender, amountIn, minAmountOut);
        }

        emit SwapExecuted(msg.sender, bestDex, amountIn, bestAmountOut);
    }
}
