// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {MyDexRouter} from "../src/MyDexRouter.sol";
import {WETH9} from "../src/v2periphery/test/WETH9.sol";
import {ERC20} from "../src/v2periphery/test/ERC20.sol";
import {UniswapV2Factory} from "../src/v2core/UniswapV2Factory.sol";
import {UniswapV2Pair} from "../src/v2core/UniswapV2Pair.sol";

contract MyDexRouterTest is Test {
    MyDexRouter public dexRouter;

    UniswapV2Factory public factory;
    WETH9 public WETH;

    ERC20 public USDT;

    address mmAdmin;
    address eoaAAA;
    address eoaBBB;
    address eoaCCC;
    address eoa444;

    uint256 bbbPrivateKey = 0x123456;

    function setUp() public {
        mmAdmin = address(0xAD888); // makeAddr("mmAdmin");
        eoaAAA = address(0xAAA111); //
        eoaBBB = vm.addr(bbbPrivateKey); //makeAddr("BBB");
        eoaCCC = address(0xccc333);
        eoa444 = address(0xddd444);

        console.log("address1:", eoaAAA);
        console.log("address2:", eoaBBB);
        console.log("address3:", eoaCCC);

        bytes memory bytecode = type(UniswapV2Pair).creationCode;
        bytes32 initCodeHash = keccak256(abi.encodePacked(bytecode));
        console.log("initCodeHash:");
        console.logBytes32(initCodeHash);

        vm.startPrank(mmAdmin);

        factory = new UniswapV2Factory(mmAdmin);
        WETH = new WETH9();
        USDT = new ERC20(10000000 * 1e18);

        dexRouter = new MyDexRouter(
            address(factory),
            address(WETH),
            address(USDT)
        );

        USDT.transfer(mmAdmin, 100 * 1e18);
        USDT.transfer(eoaAAA, 101 * 1e18);
        USDT.transfer(eoaBBB, 102 * 1e18);
        USDT.transfer(eoaCCC, 103 * 1e18);

        // eoaOwner = makeAddr("eoa1");
        deal(mmAdmin, 100 ether);
        deal(eoaAAA, 101 ether);
        deal(eoaBBB, 102 ether);
        deal(eoaCCC, 103 ether);

        USDT.approve(address(dexRouter), 20 * 1e18);
        uint256 ethAmount = 2 * 1e18;
        uint256 usdtAmount = 20 * 1e18;
        dexRouter.myAddLiquidityETH{value: ethAmount}(
            address(USDT),
            usdtAmount
        );
        console.log(
            "init price(usdt per ETH x10000):",
            (10000 * usdtAmount) / ethAmount
        );
        vm.stopPrank();
    }

    function test_sellETHUSDT() public {
        vm.startPrank(eoaAAA);
        uint256 bal1 = eoaAAA.balance;
        uint256 bal2 = WETH.balanceOf(eoaAAA);
        uint256 eoaUsdtBefore = USDT.balanceOf(eoaAAA);

        uint256 vvv1 = dexRouter.pairOfETHUSDT().balance;
        uint256 vvv2 = WETH.balanceOf(dexRouter.pairOfETHUSDT());
        uint256 pairUsdtBefore = USDT.balanceOf(dexRouter.pairOfETHUSDT());

        dexRouter.sellETHUSDT{value: 1e17}(9 * 1e17);

        uint256 bal1B = eoaAAA.balance;
        uint256 bal2B = WETH.balanceOf(eoaAAA);
        uint256 eoaUsdtAfter = USDT.balanceOf(eoaAAA);

        uint256 vvv1B = dexRouter.pairOfETHUSDT().balance;
        uint256 vvv2B = WETH.balanceOf(dexRouter.pairOfETHUSDT());
        uint256 pairUsdtAfter = USDT.balanceOf(dexRouter.pairOfETHUSDT());

        uint256 k2 = vvv2B * pairUsdtAfter;

        console.log(
            "before,eoa balance. ETH,WETH,USDT:",
            bal1,
            bal2,
            eoaUsdtBefore
        );
        console.log(
            "after ,eoa balance. ETH,WETH,USDT:",
            bal1B,
            bal2B,
            eoaUsdtAfter
        );
        console.log(
            "sell price x10000:",
            (10000 * (eoaUsdtAfter - eoaUsdtBefore)) / (bal1 - bal1B)
        );

        console.log(
            "before,pair balance. ETH,WETH,USDT:",
            vvv1,
            vvv2,
            pairUsdtBefore
        );
        console.log(
            "after ,pair balance. ETH,WETH,USDT:",
            vvv1B,
            vvv2B,
            pairUsdtAfter
        );
        console.log("k1 = ", vvv2 * pairUsdtBefore);
        console.log("k2 = ", k2);
        assertEq(eoaUsdtAfter - eoaUsdtBefore, pairUsdtBefore - pairUsdtAfter);
    }

    function test_buyETHUSDT() public {
        vm.startPrank(eoaAAA);
        uint256 bal1 = eoaAAA.balance;
        uint256 bal2 = WETH.balanceOf(eoaAAA);
        uint256 eoaUsdtBefore = USDT.balanceOf(eoaAAA);

        uint256 pairWethBefore = WETH.balanceOf(dexRouter.pairOfETHUSDT());

        USDT.approve(address(dexRouter), 170 * 1e17);
        dexRouter.buyETHUSDT(9 * 1e17, 170 * 1e17);

        uint256 bal1B = eoaAAA.balance;
        uint256 bal2B = WETH.balanceOf(eoaAAA);
        uint256 eoaUsdtAfter = USDT.balanceOf(eoaAAA);

        console.log(
            "before,eoa balance. ETH,WETH,USDT:",
            bal1,
            bal2,
            eoaUsdtBefore
        );
        console.log("before, pair's WETH balance:", pairWethBefore);
        console.log(
            "after ,eoa balance. ETH,WETH,USDT:",
            bal1B,
            bal2B,
            eoaUsdtAfter
        );
        console.log(
            "buy price x10000:",
            (10000 * (eoaUsdtBefore - eoaUsdtAfter)) / (bal1B - bal1)
        );

        assertEq(bal1B - bal1, 9 * 1e17);
    }
}
