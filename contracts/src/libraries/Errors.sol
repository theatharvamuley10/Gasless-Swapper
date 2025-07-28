// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

library Errors {
    error ZeroInputAmount();

    error ZeroAddressRecipient();

    error ZeroAddressToken();

    error SameTokens();

    error AmountOutIsZero();

    error TransferFailedFromUser();

    error ExceedingMaximumOutputLimit();

    error TransferFailedFromContract();
}
