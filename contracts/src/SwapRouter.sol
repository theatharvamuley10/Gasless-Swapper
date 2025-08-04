// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IERC20} from "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import {Errors} from "./libraries/Errors.sol";
import {MainDemoConsumerBase} from "@redstone-finance/evm-connector/contracts/data-services/MainDemoConsumerBase.sol";

contract SwapRouter is MainDemoConsumerBase {
    address private constant USDC = 0x50B22eBFDDFE3930b7580De91Af994DafD42D06C;
    address private constant WBTC = 0xb71629c0AE2a8A70f8DecD7ffa0d6251cE43960F;

    event LiquidityAdded(address indexed provider, uint256 amountA, uint256 amountB);
    event LiquidityRemoved(address indexed provider, uint256 amountA, uint256 amountB);
    event SwappedAToB(address indexed user, uint256 amountAIn, uint256 amountBOut);
    event SwappedBToA(address indexed user, uint256 amountBIn, uint256 amountAOut);

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
    {
        bytes32[] memory dataFeedIds = new bytes32[](2);
        (string memory A, string memory B) = identifyInputAndOutputTokens(tokenA, tokenB);
        dataFeedIds[0] = bytes32(abi.encode(A));
        dataFeedIds[1] = bytes32(abi.encode(B));
        uint256[] memory values = getOracleNumericValuesFromTxMsg(dataFeedIds);
        uint256 tokenAPrice = values[0];
        uint256 tokenBPrice = values[1];

        amountBOut = (amountAIn * tokenBPrice) / tokenAPrice;
    }

    function identifyInputAndOutputTokens(address tokenA, address tokenB)
        internal
        pure
        returns (string memory A, string memory B)
    {
        if (tokenA == USDC) A = "USDC";
        if (tokenA == WBTC) A = "WBTC";

        if (tokenB == USDC) {
            B = "USDC";
            return (A, B);
        }
        if (tokenB == WBTC) {
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
