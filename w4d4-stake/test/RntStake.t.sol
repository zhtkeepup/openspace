// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";

import {EsRnt} from "../src/EsRnt.sol";

import {RntERC20} from "../src/RntERC20.sol";

import {RntStake} from "../src/RntStake.sol";

contract RntStakeTest is Test {
    EsRnt public esRnt;
    RntERC20 public rnt;

    RntStake public stake;

    address mmAdmin;
    address eoaAAA;
    address eoaBBB;

    // uint256 aaaPrivateKey;

    uint256 price = 1 * 1e17; // 0.1eth/个

    uint256 presaleDays = 2; // 预售时长

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

        rnt = new RntERC20(10000);
        esRnt = new EsRnt();
        stake = new RntStake(address(rnt), address(esRnt));

        rnt.chgAdmin(address(stake)); // 转移管理员给stake合约
        esRnt.chgAdmin(address(stake));

        rnt.transfer(eoaAAA, 100 * 1e18);

        console.log("[ADDRESS]mmAdmin:", address(mmAdmin));
        console.log("[ADDRESS]eoaAAA:", address(eoaAAA));
        console.log("[ADDRESS]eoaBBB:", address(eoaBBB));

        console.log("[ADDRESS]rnt:", address(rnt));
        console.log("[ADDRESS]esRnt:", address(esRnt));
        console.log("[ADDRESS]stake:", address(stake));

        vm.stopPrank();
    }

    //
    function test_stake() public {
        vm.startPrank(eoaAAA);

        rnt.approve(address(stake), 5 * 1e18); // 质押前先授权
        uint256 t1 = block.timestamp;
        stake.stake(2 * 1e18);

        uint256 t2 = t1 + (1 days);
        vm.warp(t2);

        RntStake.StkInfoForView memory stakeInfo = stake.queryStakeInfo(eoaAAA);

        // 质押2个，1天后，获得奖励应该2个esRnt
        assertEq(stakeInfo.esRntReward, 2 * 1e18);

        console.log("amount:", stakeInfo.amount);
        console.log("esRntReward:", stakeInfo.esRntReward);

        // 再追加质押3个，并继续保持2天
        stake.stake(3 * 1e18);
        uint256 t3 = t2 + (2 days);
        vm.warp(t3);

        stakeInfo = stake.queryStakeInfo(eoaAAA);

        // 获得奖励应该 2个*3天 + 3个*1天
        assertEq(stakeInfo.esRntReward, 2 * 1e18 * 3 + 3 * 1e18 * 2);

        console.log("amount2:", stakeInfo.amount);
        console.log("esRntReward2:", stakeInfo.esRntReward);

        // ////
        // 领取奖励10天后，应该有三分之一解锁
        stake.claim();

        vm.warp(block.timestamp + 10 * 24 * 3600);
        RntStake.LockInfoForView memory lock = stake.queryLockInfo(eoaAAA);
        console.log("lockedAmount", lock.lockedAmount);
        console.log("unlockAmount", lock.unlockAmount);
        console.log("burnAmount", lock.burnAmount);

        // 未全部解锁，正常兑换应该失败
        vm.expectRevert();
        stake.exchangeEsRnt(false);

        // 超过30天之后，正常兑换后，rnt 余额应该正常增加
        uint256 balance1 = rnt.balanceOf(eoaAAA);
        vm.warp(block.timestamp + 25 * 24 * 3600);

        lock = stake.queryLockInfo(eoaAAA);
        console.log("lockedAmount22", lock.lockedAmount);
        console.log("unlockAmount22", lock.unlockAmount);
        console.log("burnAmount22", lock.burnAmount);

        stake.exchangeEsRnt(false);

        uint256 balance2 = rnt.balanceOf(eoaAAA);

        console.log("bbbb:", balance2 - balance1);

        assertEq(balance2 - balance1, lock.unlockAmount);

        lock = stake.queryLockInfo(eoaAAA);

        console.log("lockedAmount33", lock.lockedAmount);
        console.log("unlockAmount33", lock.unlockAmount);
        console.log("burnAmount33", lock.burnAmount);
    }
}
