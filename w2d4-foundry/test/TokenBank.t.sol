

/*
测试对象：TokenHook , TokenBank , NFTMarket, 
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";

import "forge-std/Test.sol";

import {TokenBank} from "../src/w2d2-erc20hook/TokenBank.sol";
import {ERC20hook} from "../src/w2d2-erc20hook/ERC20Hook.sol";



contract TokenBankTest is Test {
    
    TokenBank tokenBank; //  = new Bank();
    address token;
    address alice;
    address eve;

    function setUp() public {
        alice = makeAddr("alice");
        vm.deal(alice, 10 ether);
        
        tokenBank = new TokenBank();
        token = address(new ERC20hook());
        // vm.startPrank(alice);
    }

    function test_deposit() public {
        uint256 vv = 1000000;
        ERC20hook(token).transfer(alice, 10*vv);

        vm.startPrank(alice);

        assertEq(tokenBank.getBalance(token, alice), 0);

        ERC20hook(token).approve(address(tokenBank), 2*vv);

        tokenBank.deposit(token, vv);

        assertEq(tokenBank.getBalance(token, alice), vv);

        tokenBank.deposit(token, vv);

        assertEq(tokenBank.getBalance(token, alice), 2*vv);
    }


    function test_withdraw() public {
        uint256 vv = 1000000;
        ERC20hook(token).transfer(alice, 10*vv);

        vm.startPrank(alice);
        ERC20hook(token).approve(address(tokenBank), 5*vv);

        tokenBank.deposit(token, 5*vv);

        tokenBank.withdraw(token, 2*vv);

        assertEq(tokenBank.getBalance(token, alice), 3*vv);
    }
}