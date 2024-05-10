// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";

import {MyERC20} from "../src/MyERC20.sol";

import {ZKIDO} from "../src/ZKIDO.sol";

contract ZKIDOTest is Test {
    MyERC20 public myERC20;
    ZKIDO public zkido;

    address mmAdmin;
    address eoaAAA;
    address eoaBBB;

    uint256 aaaPrivateKey;

    uint256 price = 1 * 1e17; // 0.1eth/个

    uint256 presaleDays = 2; // 预售时长

    function setUp() public {
        aaaPrivateKey = 0xA11CE;

        mmAdmin = makeAddr("mmAdmin");
        eoaAAA = vm.addr(aaaPrivateKey);
        eoaBBB = makeAddr("BBB");

        // eoaOwner = makeAddr("eoa1");
        deal(mmAdmin, 100 ether);
        deal(eoaAAA, 101 ether);
        deal(eoaBBB, 102 ether);

        vm.startPrank(mmAdmin);

        myERC20 = new MyERC20(90); // 100个.

        /*
        address _erc20Ca,
        uint256 _presalePrice,
        uint256 _softcap, // 软顶 ETH
        uint256 _hardcap, // 硬顶 ETH
        uint256 _lifetimeInDay // 预售时长(天)
        */

        zkido = new ZKIDO(
            address(myERC20),
            price, // 价格,0.1eth/个
            (price * 90) / 2, // 软顶
            price * 90, // 硬顶 ETH(WEI)
            presaleDays // 预售时长(天)
        );

        // 转移全部代币给 zkido ,并启用ido合约
        uint256 presaleAmount = myERC20.balanceOf(mmAdmin);

        myERC20.transfer(address(zkido), presaleAmount);

        zkido.enable(presaleAmount);

        console.log("[ADDRESS]mmAdmin:", address(mmAdmin), presaleAmount);
        console.log("[ADDRESS]myERC20:", address(myERC20));
        console.log("[ADDRESS]zkido:", address(zkido));

        vm.stopPrank();
    }

    //
    function test_ZKIDO1() public {
        vm.startPrank(eoaAAA);

        uint256 aBalance1 = eoaAAA.balance;
        uint256 psEth1 = zkido.presaleCap();
        console.log("test_ZKIDO1:", aBalance1, psEth1);

        zkido.preSale{value: 10 * price}(10 * 1e18);

        console.log("pre buy:", 10);

        uint256 aBalance2 = eoaAAA.balance;
        uint256 psEth2 = zkido.presaleCap();

        console.log("test_ZKIDO2:", aBalance2, psEth2);
        console.log("price:", zkido.presalePrice());

        assertEq(psEth2 - psEth1, aBalance1 - aBalance2);

        assertEq(psEth2 - psEth1, 10 * zkido.presalePrice());

        vm.stopPrank();

        // /////////////
        // 第二个用户
        vm.startPrank(eoaBBB);
        aBalance1 = eoaBBB.balance;
        psEth1 = zkido.presaleCap();
        console.log("test_XXZKIDO1:", aBalance1, psEth1);

        zkido.preSale{value: 100 * price}(100 * 1e18);

        console.log("pre buy:", 100);

        aBalance2 = eoaBBB.balance;
        psEth2 = zkido.presaleCap();

        console.log("test_XXZKIDO2:", aBalance2, psEth2);
        console.log("price:", price);

        assertEq(psEth2 - psEth1, aBalance1 - aBalance2);

        assertEq(psEth2 - psEth1, 100 * price);

        // //
        uint256 xx = block.timestamp + presaleDays * 24 * 3600 + 1;
        vm.warp(xx);

        // 超额募资，claim一下，每人最终获取的数量应该变少，同时多余的eth将返还
        // B 用户:
        uint256 tkBalance1 = myERC20.balanceOf(eoaBBB);
        uint256 ethBalance1 = eoaBBB.balance;
        uint256 idoTkBalance1 = myERC20.balanceOf(address(zkido));
        uint256 idoEthBalance1 = address(zkido).balance;
        console.log("BBB before claim, b balance:", tkBalance1, ethBalance1);
        console.log(
            "BBB before claim, ido balance:",
            idoTkBalance1,
            idoEthBalance1
        );

        zkido.claim(); ///////////

        uint256 tkBalance2 = myERC20.balanceOf(eoaBBB);
        uint256 ethBalance2 = eoaBBB.balance;
        uint256 idoTkBalance2 = myERC20.balanceOf(address(zkido));
        uint256 idoEthBalance2 = address(zkido).balance;
        console.log("BBB after claim, b balance:", tkBalance2, ethBalance2);
        console.log(
            "BBB after claim, ido balance:",
            idoTkBalance2,
            idoEthBalance2
        );
        // BBB用户，
        assertEq(idoEthBalance1 - idoEthBalance2, ethBalance2 - ethBalance1);
        assertEq(idoTkBalance1 - idoTkBalance2, tkBalance2 - tkBalance1);

        // 最初花费 100 * price 参与预售 ，计算一下实际单价与 [0.1ETH每个] 的差额
        console.log(
            "price1:",
            (((100 * price) - (ethBalance2 - ethBalance1)) * 1e18) /
                (tkBalance2 - tkBalance1)
        );
        console.log("price2:", 1e17);

        // 其他场景测试.......
        // .....
    }
}
