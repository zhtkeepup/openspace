// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";

import {KKToken} from "../src/KKToken.sol";

import {Staking} from "../src/Staking.sol";

contract StakingTest is Test {
    KKToken public kk;

    Staking public ss;

    address mmAdmin;
    address eoaAAA;
    address eoaBBB;

    function setUp() public {
        // aaaPrivateKey = 0xA11CE;

        mmAdmin = address(0xAD888); // makeAddr("mmAdmin");
        eoaAAA = address(0xAAA111); // vm.addr(aaaPrivateKey);
        eoaBBB = address(0xBBB222); //makeAddr("BBB");

        // eoaOwner = makeAddr("eoa1");
        deal(mmAdmin, 100 ether);
        deal(eoaAAA, 101 ether);
        deal(eoaBBB, 102 ether);

        vm.startPrank(mmAdmin);

        kk = new KKToken();
        ss = new Staking(address(kk));
        kk.setStaking(address(ss));

        console.log("[ADDRESS]mmAdmin:", address(mmAdmin));
        console.log("[ADDRESS]eoaAAA:", address(eoaAAA));
        console.log("[ADDRESS]eoaBBB:", address(eoaBBB));

        console.log("[ADDRESS]kk:", address(kk));
        console.log("[ADDRESS]ss:", address(ss));

        vm.stopPrank();
    }

    //
    function test_staking1() public {
        vm.startPrank(eoaAAA);

        uint256 n1 = block.number;

        ss.stake{value: 10 * 1e18}();

        uint256 n2 = n1 + (2);
        vm.roll(n2);
        ss.claim();

        // 经过2个区块之后，一个质押用户获得全部的代币奖励, 2*10
        console.log("aaa:", kk.balanceOf(eoaAAA));

        assertEq(20 * 1e18, kk.balanceOf(eoaAAA));

        // RntStake.StkInfoForView memory stakeInfo = stake.queryStakeInfo(eoaAAA);

        // // 质押2个，1天后，获得奖励应该2个esRnt
        // assertEq(stakeInfo.esRntReward, 2 * 1e18);

        // console.log("amount:", stakeInfo.amount);
        // console.log("esRntReward:", stakeInfo.esRntReward);

        // // 再追加质押3个，并继续保持2天
        // stake.stake(3 * 1e18);
        // uint256 t3 = t2 + (2 days);
        // vm.warp(t3);

        // stakeInfo = stake.queryStakeInfo(eoaAAA);

        // // 获得奖励应该 2个*3天 + 3个*1天
        // assertEq(stakeInfo.esRntReward, 2 * 1e18 * 3 + 3 * 1e18 * 2);

        // console.log("amount2:", stakeInfo.amount);
        // console.log("esRntReward2:", stakeInfo.esRntReward);

        // // ////
        // // 领取奖励10天后，应该有三分之一解锁
        // stake.claim();

        // vm.warp(block.timestamp + 10 * 24 * 3600);
        // RntStake.LockInfoForView memory lock = stake.queryLockInfo(eoaAAA);
        // console.log("lockedAmount", lock.lockedAmount);
        // console.log("unlockAmount", lock.unlockAmount);
        // console.log("burnAmount", lock.burnAmount);

        // // 未全部解锁，正常兑换应该失败
        // vm.expectRevert();
        // stake.exchangeEsRnt(false);

        // // 超过30天之后，正常兑换后，rnt 余额应该正常增加
        // uint256 balance1 = rnt.balanceOf(eoaAAA);
        // vm.warp(block.timestamp + 25 * 24 * 3600);

        // lock = stake.queryLockInfo(eoaAAA);
        // console.log("lockedAmount22", lock.lockedAmount);
        // console.log("unlockAmount22", lock.unlockAmount);
        // console.log("burnAmount22", lock.burnAmount);

        // stake.exchangeEsRnt(false);

        // uint256 balance2 = rnt.balanceOf(eoaAAA);

        // console.log("bbbb:", balance2 - balance1);

        // assertEq(balance2 - balance1, lock.unlockAmount);

        // lock = stake.queryLockInfo(eoaAAA);

        // console.log("lockedAmount33", lock.lockedAmount);
        // console.log("unlockAmount33", lock.unlockAmount);
        // console.log("burnAmount33", lock.burnAmount);
    }

    function test_staking2() public {
        vm.startPrank(eoaAAA);

        uint256 n1 = block.number;

        ss.stake{value: 8 * 1e18}();

        vm.startPrank(eoaBBB);

        ss.stake{value: 2 * 1e18}();

        uint256 n2 = n1 + (2);

        vm.roll(n2);

        vm.startPrank(eoaAAA);
        ss.claim();

        vm.startPrank(eoaBBB);
        ss.claim();

        // 经过3个区块之后，一个质押用户获得全部的代币奖励, AAA用户获得奖励 20，BBB用户获得奖励10

        console.log("aaa:", kk.balanceOf(eoaAAA));
        console.log("bbb:", kk.balanceOf(eoaBBB));

        assertEq(16 * 1e18, kk.balanceOf(eoaAAA));
        assertEq(4 * 1e18, kk.balanceOf(eoaBBB));
    }

    function test_staking3() public {
        vm.startPrank(eoaAAA);

        uint256 n0 = block.number;

        ss.stake{value: 1 * 1e18}();

        vm.roll(n0 + 10);

        vm.startPrank(eoaBBB);

        ss.stake{value: 4 * 1e18}();

        vm.roll(n0 + 10 + 20);

        vm.startPrank(eoaAAA);
        ss.claim();

        vm.startPrank(eoaBBB);
        ss.claim();

        // 全部奖励: 30*10=300,  aaa=10*10+ 200*1/5

        console.log("aaa:", kk.balanceOf(eoaAAA));
        console.log("bbb:", kk.balanceOf(eoaBBB));

        assertEq(140 * 1e18, kk.balanceOf(eoaAAA));
        assertEq(160 * 1e18, kk.balanceOf(eoaBBB));
    }
}
