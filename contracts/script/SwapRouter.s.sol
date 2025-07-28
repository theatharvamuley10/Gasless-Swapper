// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {SwapRouter} from "src/SwapRouter.sol";

contract Deployer is Script {
    function run() external {
        vm.startBroadcast();
        new SwapRouter();
        vm.stopBroadcast();
    }
}
