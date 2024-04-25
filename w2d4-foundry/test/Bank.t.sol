// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";

import "forge-std/Test.sol";

import {Bank} from "../src/Bank.sol";


/**
给Bank合约的 DepositETH 方法编写测试，检查事件输出是否符合预期，检查 balanceOf 余额更新是否符合预期
 */
contract BankTest is Test {
    
    Bank bank; //  = new Bank();

    address alice;
    address eve;

    function setUp() public {
        alice = makeAddr("alice");
        vm.startPrank(alice);
        vm.deal(alice, 10 ether);
        eve = makeAddr("eve");
        vm.deal(eve, 2 ether);
        bank = new Bank();
    }

    function test_DepositETH() public {
        assertEq(bank.balanceOf(alice), 0);
        
        console.log("Alice balance before deposit:", alice.balance);
        // console.log("Eve balance", eve.balance);
        vm.startPrank(alice);

        vm.expectCall(
            address(bank),
            2 ether,
            abi.encodeWithSelector(bank.depositETH.selector)
        );
        bank.depositETH{value: 2 ether}();

        console.log("Alice balance after deposit:", alice.balance);

        assertEq(bank.balanceOf(alice), 2 ether);

        vm.stopPrank();
    }


}
