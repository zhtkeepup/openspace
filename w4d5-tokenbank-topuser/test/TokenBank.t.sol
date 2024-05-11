// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {MyERC20} from "../src/MyERC20.sol";

contract CounterTest is Test {
    MyERC20 public myERC20;
    TokenBank public tokenBank;

    address[] adds;

    function setUp() public {
        myERC20 = new MyERC20("ZK1", 1000000);
        tokenBank = new TokenBank(address(myERC20));

        for (uint160 k = 0x1100; k <= 0x1100 + 0x0f; k++) {
            adds.push(address(k));
            myERC20.transfer(address(k), k);
        }
    }

    function test_bankOrder() public {
        // 模拟，金额最大的，最后存入
        for (uint256 k = 0; k <= 0x0f; k++) {
            vm.startPrank(adds[k]);
            myERC20.approve(address(tokenBank), 1000000);
            tokenBank.deposit(k + 1);
            console.log("deposit:", adds[k], k + 1);
            vm.stopPrank();
        }

        // 金额最大(地址值最小)的地址应该在最前面
        address[10] memory top10Addr = tokenBank.queryTop10();
        for (uint256 k = 0; k < 10; k++) {
            console.log("----", k, ":", top10Addr[k]);
        }

        assertEq(top10Addr[0], adds[0x0f]);
    }
}
