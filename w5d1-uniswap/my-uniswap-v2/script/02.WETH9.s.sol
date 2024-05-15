// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {WETH9} from "../src/v2periphery/test/WETH9.sol";

contract WETH9Script is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        WETH9 weth9 = new WETH9();
        // 0xcbAF78Ab27f9a1F5Ec0f2DC5152e61bBb0c5DDD2
        // vm.stopBroadcast();
    }
}
