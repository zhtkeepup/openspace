// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyWallet} from "../src/MyWallet.sol";

contract MyWalletTest is Test {
    MyWallet public myWallet;

    function setUp() public {
        myWallet = new MyWallet("NNN");
    }

    function test_ttt1() public {
        console.log("aaa:", myWallet.owner());
        myWallet.transferOwernship(address(0xABC));
        console.log("bbb:", myWallet.owner());
        console.log("ccc:", myWallet.getOwner());

        vm.startPrank(address(0xABC));
        myWallet.setOwner(address(0x7788));
        console.log("bbb22:", myWallet.owner());
        console.log("ccc22:", myWallet.getOwner());
    }
}
