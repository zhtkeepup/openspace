// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {TokenBank} from "../src/TokenBank.sol";
import {MyERC20With2612Permit as Token} from "../src/MyERC20With2612Permit.sol";
import {SigUtils} from "../src/SigUtils.sol";

contract TokenBankTest is Test {
    TokenBank public tokenBank;
    Token public token;
    SigUtils public sigUtils;

    address eoaOwner;
    address eoaAAA;

    uint256 ownerPrivateKey;
    uint256 spenderPrivateKey;

    function setUp() public {
        tokenBank = new TokenBank();
        token = new Token();
        console.log("[ADDRESS]tokenBank:", address(tokenBank));
        console.log("[ADDRESS]token:", address(token));

        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        ownerPrivateKey = 0xA11CE;
        spenderPrivateKey = 0xB0B;

        eoaOwner = vm.addr(ownerPrivateKey);
        eoaAAA = makeAddr("AAA");

        token.transfer(eoaOwner, 3 * 1e18);

        // eoaOwner = makeAddr("eoa1");
        deal(eoaOwner, 100 ether);
        deal(eoaAAA, 101 ether);
        // vm.startPrank(eoa1);
    }

    // 测试离线签名存款
    function test_permitDepositFail() public {
        ////
        ////////////// 通过签名授权给一个非银行账户
        SigUtils.Permit memory permitAAA = SigUtils.Permit({
            owner: eoaOwner,
            spender: eoaAAA, // 通过签名授权给一个非银行账户
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 3600 * 24
        });
        // eoaOwner在链下签名给非银行账户
        bytes32 digestAAA = sigUtils.getTypedDataHash(permitAAA);
        (uint8 vAAA, bytes32 rAAA, bytes32 sAAA) = vm.sign(
            ownerPrivateKey,
            digestAAA
        );

        // //////////

        //
        // 无签名直接存款，应该失败
        vm.expectRevert();

        tokenBank.permitDeposit(
            permitAAA.owner,
            address(token),
            permitAAA.value,
            permitAAA.deadline,
            0,
            0,
            0
        );

        // 使用 “授权给[非银行]的签名” ，应该也失败
        vm.expectRevert();

        tokenBank.permitDeposit(
            permitAAA.owner,
            address(token),
            permitAAA.value,
            permitAAA.deadline,
            vAAA,
            rAAA,
            sAAA
        );
    }

    // 测试离线签名存款
    function test_permitDepositOK() public {
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: eoaOwner,
            spender: address(tokenBank), // 通过签名授权给银行
            value: 1e18,
            nonce: 0,
            deadline: block.timestamp + 3600 * 24
        });
        // eoaOwner在链下签名
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(ownerPrivateKey, digest);

        ////
        //
        // 使用授权给银行的签名，应该成功
        uint256 bankBalance = token.balanceOf(address(tokenBank));
        uint256 ownerBalance = token.balanceOf(eoaOwner);
        console.log("bank:", bankBalance, "  owner:", ownerBalance);

        tokenBank.permitDeposit(
            permit.owner,
            address(token),
            permit.value,
            permit.deadline,
            v,
            r,
            s
        );

        uint256 bankBalance2 = token.balanceOf(address(tokenBank));
        uint256 ownerBalance2 = token.balanceOf(eoaOwner);
        console.log("bank2:", bankBalance2, "  owner:", ownerBalance2);

        assertEq(bankBalance + 1e18, bankBalance2);
        assertEq(ownerBalance - 1e18, ownerBalance2);
    }
}
