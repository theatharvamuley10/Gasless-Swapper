// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import {Script} from "forge-std/Script.sol";
import {MockERC20} from "src/mocks/MockERC20.sol";

contract Deployer is Script {
    address private constant ACCOUNT_ONE =
        0x88BCe67C0259107003B2178f920fB898C65b97ea;

    function run() external {
        vm.startBroadcast();
        new MockERC20("USD Coin", "USDC", ACCOUNT_ONE);
        new MockERC20("Wrapped BTC", "WBTC", ACCOUNT_ONE);
        vm.stopBroadcast();
    }
}
