// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {MyDexRouter} from "../src/MyDexRouter.sol";

contract MyDexRouterScript is Script {
    address public constant _factory =
        0xe55ffbacB9085CD5fdB02E72C09B676F95081dCC;
    address public constant _WETH = 0xcbAF78Ab27f9a1F5Ec0f2DC5152e61bBb0c5DDD2;
    address public constant _USDT = address(0);

    function setUp() public {}

    function run() public {
        vm.broadcast();

        MyDexRouter myDex = new MyDexRouter(_factory, _WETH, _USDT);
        // 0xcbAF78Ab27f9a1F5Ec0f2DC5152e61bBb0c5DDD2
        // vm.stopBroadcast();
    }
}
