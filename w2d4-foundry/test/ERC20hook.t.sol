

/*
测试对象：TokenBank，NFTMarket, TokenHook 
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";

import "forge-std/Test.sol";

import {ERC20hook} from "../src/w2d2-erc20hook/ERC20hook.sol";

/*
测试对象：TokenHook , TokenBank , NFTMarket, 
*/

contract ERC20hookTest is Test {
    
    ERC20hook myContract; //  = new Bank();

    address alice;
    address eve;
    address ccc;

    function setUp() public {
        alice = makeAddr("alice");
        eve = makeAddr("eve");
        ccc = makeAddr("ccc");

        vm.deal(alice, 10 ether);
        vm.deal(eve, 1 ether);
        
        myContract = new ERC20hook();
        
        // vm.startPrank(alice);
    }
    
    function test_balanceOfCreator() public {
        assertEq(myContract.balanceOf(address(this)), myContract.totalSupply());
    }


    function test_transfer() public {
        uint256 val = 50 * 10**18;
        console.log("my balance before transfer:", myContract.balanceOf(address(this)));
        myContract.transfer(eve, val);
        console.log("my balance and eve's balance after transfer:", 
            myContract.balanceOf(address(this)),
            myContract.balanceOf(eve));
        assertEq(myContract.balanceOf(eve), 50 * 1e18);
        assertEq(myContract.balanceOf(address(this)), myContract.totalSupply() - val);
    }

    function testFail_noApprov() public {
        uint256 val = 1e18;
        myContract.transfer(eve, val*2);
        // myContract.prank(eve);
        myContract.transferFrom(eve, ccc, val);
    }

    function test_withApprov() public {
        uint256 val = 1e18;
        myContract.transfer(eve, val*2);
        
        vm.startPrank(eve);
        myContract.approve(address(this), val*3);
        vm.stopPrank();

        assertEq(myContract.allowance(eve, address(this)), val*3 );

        myContract.transferFrom(eve, ccc, val);

        assertEq(myContract.allowance(eve, address(this)), val*2 );
    }

}