// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Script, console} from "forge-std/Script.sol";

import {UniswapV2Factory} from "../src/v2core/UniswapV2Factory.sol";

contract UniswapV2FactoryScript is Script {
    function setUp() public {}

    function run() public {
        vm.broadcast();

        address _feeToSetter = address(
            0xE249dfD432B37872C40c0511cC5A3aE13906F77A
        );
        UniswapV2Factory swapFactory = new UniswapV2Factory(_feeToSetter);
        // 0xe55ffbacB9085CD5fdB02E72C09B676F95081dCC
        // vm.stopBroadcast();
    }
}
