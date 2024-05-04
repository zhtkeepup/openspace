// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";

import {MyERC721} from "../src/nft/MyERC721.sol";
import {MyNFTMarket} from "../src/MyNFTMarket.sol";
import {MyERC20With2612Permit as Token} from "../src/MyERC20With2612Permit.sol";
import {MarketWhitelistPermitLib} from "../src/MarketWhitelistPermitLib.sol";

contract TokenBankTest is Test {
    MyNFTMarket public myNFTMarket;
    Token public token;
    MyERC721 nft;

    address marketAdmin;
    address eoaAAA;
    address eoaBBB;

    uint256 marketAdminPrivateKey;

    //
    uint8 v;
    bytes32 r;
    bytes32 s;

    MarketWhitelistPermitLib.Permit permit;
    bytes32 digest;

    function setUp() public {
        marketAdminPrivateKey = 0xA11CE;

        marketAdmin = vm.addr(marketAdminPrivateKey);
        eoaAAA = makeAddr("AAA");
        eoaBBB = makeAddr("BBB");

        // eoaOwner = makeAddr("eoa1");
        deal(marketAdmin, 100 ether);
        deal(eoaAAA, 101 ether);
        deal(eoaBBB, 102 ether);

        vm.startPrank(marketAdmin);

        nft = new MyERC721();
        nft.mint(marketAdmin, 1);

        token = new Token();

        token.transfer(eoaAAA, 3 * 1e18);
        token.transfer(eoaBBB, 3 * 1e18);

        myNFTMarket = new MyNFTMarket(address(token), address(nft));

        nft.approve(address(myNFTMarket), 1);

        myNFTMarket.list(1, 100); // list之前先授权给市场.

        console.log("[ADDRESS]myNFTMarket:", address(myNFTMarket));
        console.log("[ADDRESS]token:", address(token));
        console.log("[ADDRESS]nft:", address(nft));

        // 为eoaAAA生成白名单签名
        permit = MarketWhitelistPermitLib.Permit({
            admin: marketAdmin,
            whiteUser: eoaAAA,
            nonce: 0
        });
        digest = MarketWhitelistPermitLib.getTypedDataHash(
            permit,
            myNFTMarket.DOMAIN_SEPARATOR()
        );
        (v, r, s) = vm.sign(marketAdminPrivateKey, digest);

        vm.stopPrank();
    }

    // 非白名单用户eoaBBB购买应该失败
    function test_fail_permitBuy() public {
        // console.log("222 compare====:");
        // console.logBytes32(digest);
        // console.log("333 compare====:");
        // console.logBytes32(
        //     MarketWhitelistPermitLib.getTypedDataHash2(
        //         permit,
        //         myNFTMarket.DOMAIN_SEPARATOR()
        //     )
        // );

        vm.startPrank(eoaBBB);
        token.approve(address(myNFTMarket), 100);
        vm.expectRevert();
        myNFTMarket.permitBuy(1, 100, v, r, s);

        //
    }

    // 白名单用户eoaAAA购买应该成功
    function test_ok_permitBuy() public {
        vm.startPrank(eoaAAA);
        token.approve(address(myNFTMarket), 100);
        console.log(nft.balanceOf(eoaAAA), "xxx1:", token.balanceOf(eoaAAA));
        myNFTMarket.permitBuy(1, 100, v, r, s);
        //
        console.log(nft.balanceOf(eoaAAA), "xxx2:", token.balanceOf(eoaAAA));

        assertEq(nft.balanceOf(eoaAAA), 1);
    }
}
