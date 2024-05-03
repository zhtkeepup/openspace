// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {Test, console} from "forge-std/Test.sol";
import {MyERC20InscFactory} from "../src/MyERC20InscFactory.sol";
import {MyERC20InscImpl} from "../src/MyERC20InscImpl.sol";
import {MyERC20InscMin} from "../src/MyERC20InscMin.sol";

contract MyERC20InscFactoryTest is Test {
    MyERC20InscFactory public myERC20InscFactory;
    MyERC20InscImpl public myERC20InscImpl;

    address eoa1;
    address eoa2;

    function setUp() public {
        myERC20InscFactory = new MyERC20InscFactory();
        myERC20InscImpl = MyERC20InscImpl(myERC20InscFactory.implementation());
        console.log("[ADDRESS]myERC20InscImpl:", address(myERC20InscImpl));
        console.log(
            "[ADDRESS]myERC20InscFactory:",
            address(myERC20InscFactory)
        );

        eoa1 = makeAddr("eoa1");
        eoa2 = makeAddr("eoa2");
        deal(eoa1, 100 ether);
        deal(eoa2, 101 ether);
    }

    uint256 total = 21000000;
    uint256 perMint = 1000;
    uint256 price = 5;

    function ff_deploy(string memory inscName) public returns (address) {
        console.log("1111:", myERC20InscFactory.inscContracts(inscName));

        address a = myERC20InscFactory.deployInscription(
            inscName,
            total,
            perMint,
            price
        );

        console.log(
            "[ADDRESS]INSC INSTANCE:",
            myERC20InscFactory.inscContracts(inscName)
        );
        return a;
    }

    function test_deployInscription() public {
        console.log("test_deployInscription......");

        address a = ff_deploy("INSC001");

        // deploy之后判断合约地址
        assertEq(
            a,
            myERC20InscFactory.inscContracts("INSC001"),
            "contract address error"
        );

        // deploy之后，合约地址本身的余额应该和总量相等
        assertEq(
            MyERC20InscMin(payable(a)).balanceOf(a),
            total * 1e18,
            "deploy amount error"
        );
    }

    function test_mint() public {
        console.log("test_mint......");

        vm.startPrank(eoa1);

        address a11 = ff_deploy("INSC001");
        address payable a = payable(a11);

        uint256 ethBalance1 = eoa1.balance;
        uint256 tokenBalance1 = MyERC20InscMin(a).balanceOf(eoa1);
        console.log("tokenBalance1:", tokenBalance1);
        console.log("ETHBalance1:", ethBalance1);

        console.log("FactoryETHBalance1:", address(myERC20InscFactory).balance);

        // mint需要的费用
        uint256 chargeInWei = MyERC20InscMin(a).mintChargeInWei();

        myERC20InscFactory.mintInscription{value: chargeInWei}(a);

        uint256 ethBalance2 = eoa1.balance;
        uint256 tokenBalance2 = MyERC20InscMin(a).balanceOf(eoa1);
        console.log("tokenBalance2:", tokenBalance2);
        console.log("ETHBalance2:", ethBalance2);

        console.log("FactoryETHBalance2:", address(myERC20InscFactory).balance);

        // mint一次 之后， 我的以太币余额减少了 2 . 支付的手续费被工厂收走了，但mint的费用又重新还给我自己

        // mint之后，我的余额应该增加 perMint
        assertEq(
            tokenBalance1 + perMint * 1e18,
            tokenBalance2,
            "balance error after mint"
        );

        // 切换另一个账户来mint
        vm.stopPrank();
        vm.startPrank(eoa2);

        ethBalance1 = eoa2.balance;
        tokenBalance1 = MyERC20InscMin(a).balanceOf(eoa2);

        myERC20InscFactory.mintInscription{value: chargeInWei}(a);
        myERC20InscFactory.mintInscription{value: chargeInWei}(a);

        ethBalance2 = eoa2.balance;
        tokenBalance2 = MyERC20InscMin(a).balanceOf(eoa2);

        console.log("tokenBalance2bbb:", tokenBalance2);
        console.log("ETHBalance2bbb:", ethBalance2);

        console.log(
            "FactoryETHBalance2bbb:",
            address(myERC20InscFactory).balance
        );

        // mint两次
        assertEq(
            tokenBalance1 + 2 * perMint * 1e18,
            tokenBalance2,
            "balance error after mint 2"
        );

        assertEq(ethBalance1 - 2 * price * perMint, ethBalance2);
    }

    // mint 总额不应该超过 totalSupply
    function test_mintLimit() public {
        console.log("test_mintLimit......");

        total = 10;
        perMint = 5;

        vm.startPrank(eoa1);

        address a11 = ff_deploy("INSC001");
        address payable a = payable(a11);

        vm.startPrank(eoa2);
        uint256 chargeInWei = MyERC20InscMin(a).mintChargeInWei();
        uint256 k = 0;
        while (true) {
            myERC20InscFactory.mintInscription{value: chargeInWei}(a);
            k += 1;
            if (k + 1 > total / perMint) {
                break;
            }
        }

        console.log("kkkk:", k);

        vm.expectRevert();
        // 超过限额的mint应该出错
        myERC20InscFactory.mintInscription{value: chargeInWei}(a);
    }
}
