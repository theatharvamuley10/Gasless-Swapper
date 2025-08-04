// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {BasePaymaster} from "account-abstraction/core/BasePaymaster.sol";
import {PackedUserOperation} from "account-abstraction/interfaces/PackedUserOperation.sol";
import {IEntryPoint} from "account-abstraction/interfaces/IEntryPoint.sol";
import {SIG_VALIDATION_FAILED, SIG_VALIDATION_SUCCESS} from "account-abstraction/core/Helpers.sol";

contract Paymaster is BasePaymaster {
    address private immutable i_swapRouter;
    /*//////////////////////////////////////////////////////////////
                              CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    constructor(address entryPoint, address swapRouter) BasePaymaster(IEntryPoint(entryPoint)) {
        i_swapRouter = swapRouter;
    }

    /*//////////////////////////////////////////////////////////////
                           EXTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function validatePaymasterUserOp(PackedUserOperation calldata userOp, bytes32 userOpHash, uint256 maxCost)
        external
        override
        returns (bytes memory context, uint256 validationData)
    {
        _requireFromEntryPoint();
        return _validatePaymasterUserOp(userOp, userOpHash, maxCost);
    }

    function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost, uint256 actualUserOpFeePerGas)
        external
        override
    {
        _requireFromEntryPoint();
        _postOp(mode, context, actualGasCost, actualUserOpFeePerGas);
    }

    /*//////////////////////////////////////////////////////////////
                           INTERNAL FUNCTIONS
    //////////////////////////////////////////////////////////////*/
    function _validatePaymasterUserOp(
        PackedUserOperation calldata userOp,
        bytes32, // extraData, unused
        uint256 // required by interface, unused
    ) internal view override returns (bytes memory context, uint256 validationData) {
        context = hex"";

        // Replace with your SwapRouter contract address
        address swapRouter = i_swapRouter;

        // Replace with your swap function selector (example: bytes4(keccak256("swap(address,uint256)")))
        bytes4 swapSelector = bytes4(keccak256("swap(address,uint256)"));

        bytes calldata callData = userOp.callData;
        if (callData.length < 4 + 32 * 3) {
            // 4 bytes selector + 3 static 32-byte args at least
            // Malformed or incomplete calldata
            return (context, SIG_VALIDATION_FAILED);
        }

        // Step 1: check if function selector is MinimalAccount.execute
        bytes4 executeSelector = bytes4(callData[0:4]);
        // Replace with actual selector for your execute function if not standard
        if (executeSelector != bytes4(keccak256("execute(address,uint256,bytes)"))) {
            return (context, SIG_VALIDATION_FAILED);
        }

        // Step 2: decode 'target' address from calldata (next 32 bytes after selector, position 4~36)
        address target;
        assembly {
            target := calldataload(add(callData.offset, 4))
        }

        // Step 3: locate the offset of 'data' (bytes argument)
        uint256 dataOffset;
        assembly {
            dataOffset := calldataload(add(callData.offset, 68)) // 4 selector + 2x32 = 68
            dataOffset := add(callData.offset, dataOffset)
        }

        // Step 4: extract function selector inside the embedded data
        bytes4 innerSelector;
        if (callData.length >= dataOffset + 4) {
            assembly {
                innerSelector := calldataload(dataOffset)
            }
        } else {
            return (context, SIG_VALIDATION_FAILED);
        }

        // Step 5: Check if the call goes to SwapRouter and calls swap function
        if (target == swapRouter && innerSelector == swapSelector) {
            return (context, SIG_VALIDATION_SUCCESS);
        } else {
            return (context, SIG_VALIDATION_FAILED);
        }
    }

    function _postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost, uint256 actualUserOpFeePerGas)
        internal
        override
    {
        (mode, context, actualGasCost, actualUserOpFeePerGas); // unused params
        // subclass must override this method if validatePaymasterUserOp returns a context
        revert("must override");
    }
}
