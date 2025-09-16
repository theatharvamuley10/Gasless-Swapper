// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Errors} from "./libraries/Errors.sol";
import {IDataFeedsCache} from "@chainlink/contracts/src/v0.8/data-feeds/interfaces/IDataFeedsCache.sol";

contract SwapRouter {
    address private immutable ETH;
    address private immutable BTC;
    IDataFeedsCache private constant PRICE_FEED = 0x5fb1616F78dA7aFC9FF79e0371741a747D2a7F22;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event SwappedAToB(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwappedBToA(address indexed user, uint256 amountBIn, uint256 amountAOut);

    constructor(address _ETH, address _BTC) {
        ETH = _ETH;
        BTC = _BTC;
    }

    function checkValidInput(uint256 amountIn, address recipient, address tokenA, address tokenB) internal pure {
        if (amountIn == 0) revert Errors.ZeroInputAmount();
        if (recipient == address(0)) revert Errors.ZeroAddressRecipient();
        if (!(tokenA == address(0) && tokenB == address(0))) {
            revert Errors.ZeroAddressToken();
        }
        if (tokenA == tokenB) revert Errors.SameTokens();
    }

    function getAmountOut(uint256 amountAIn, address tokenA, address tokenB)
        internal
        view
        returns (uint256 amountBOut)
    {}

    function identifyInputAndOutputTokens(address tokenA, address tokenB)
        internal
        pure
        returns (string memory A, string memory B)
    {
        if (tokenA == ETH) A = "USDC";
        if (tokenA == BTC) A = "WBTC";

        if (tokenB == BTC) {
            B = "USDC";
            return (A, B);
        }
        if (tokenB == ETH) {
            B = "WBTC";
            return (A, B);
        }
    }

    function swapExactInputSingle(uint256 amountAIn, address recipient, address tokenA, address tokenB)
        external
        returns (uint256 amountBOut)
    {
        checkValidInput(amountAIn, recipient, tokenA, tokenB);

        amountBOut = getAmountOut(amountAIn, tokenA, tokenB);
        if (amountBOut == 0) revert Errors.AmountOutIsZero();

        IERC20 _tokenA = IERC20(tokenA);
        IERC20 _tokenB = IERC20(tokenB);

        bool successA = _tokenA.transferFrom(msg.sender, address(this), amountAIn);
        if (!successA) revert Errors.TransferFailedFromUser();

        if (_tokenB.balanceOf(address(this)) < amountBOut) {
            revert Errors.ExceedingMaximumOutputLimit();
        }

        bool successB = _tokenB.transfer(msg.sender, amountBOut);
        if (!successB) revert Errors.TransferFailedFromContract();

        emit SwappedAToB(msg.sender, amountAIn, amountBOut);
    }
}
