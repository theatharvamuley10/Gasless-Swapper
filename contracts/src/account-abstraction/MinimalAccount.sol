// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BaseAccount} from "account-abstraction/core/BaseAccount.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {Ownable} from "@openzeppelin/contracts/access/Ownable.sol";
import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";
import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {SIG_VALIDATION_SUCCESS, SIG_VALIDATION_FAILED} from "account-abstraction/core/Helpers.sol";

contract MinimalAccount is BaseAccount, Ownable {
    error MinimalAccount__CallFailed();

    using MessageHashUtils for bytes32;

    /*//////////////////////////////////////////////////////////////
                            STATE VARIABLES
    //////////////////////////////////////////////////////////////*/
    IEntryPoint immutable i_entryPoint;

    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/
    constructor(address entryPointAddress, address owner) Ownable(owner) {
        i_entryPoint = IEntryPoint(entryPointAddress);
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function validateUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        virtual
        override
        returns (uint256 validationData)
    {
        _requireFromEntryPoint();
        validationData = _validateSignature(userOp, userOpHash);
        _validateNonce(userOp.nonce);
        _payPrefund(missingAccountFunds);
    }

    function execute(address target, uint256 value, bytes calldata data) external override onlyOwner {
        _requireFromEntryPoint();
        (bool success, bytes memory result) = target.call{value: value}(data);
        if (!success) revert MinimalAccount__CallFailed();
    }

    function entryPoint() public view override returns (IEntryPoint) {
        return i_entryPoint;
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _validateSignature(PackedUserOperation calldata userOp, bytes32 userOpHash)
        internal
        virtual
        override
        returns (uint256 validationData)
    {
        bytes32 digest = userOpHash.toEthSignedMessageHash();
        address signer = ECDSA.recover(digest, userOp.signature);

        if (signer == owner()) return SIG_VALIDATION_SUCCESS;
        else return SIG_VALIDATION_FAILED;
    }
}
