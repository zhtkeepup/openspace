// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "../lib/forge-std/src/Test.sol";

import {MyERC721} from "../src/nft/MyERC721.sol";

import {MyERC20With2612Permit as Token} from "../src/MyERC20With2612Permit.sol";

import {MyNFTMarketProxy} from "../src/MyNFTMarketProxy.sol";
import {MyNFTMarketV1} from "../src/MyNFTMarketV1.sol";
import {MyNFTMarketV2} from "../src/MyNFTMarketV2.sol";

import {MyNFTMarketV2Permit} from "../src/MyNFTMarketV2Permit.sol";

contract TokenBankTest is Test {
    MyNFTMarketV1 public myNFTMarketV1;
    MyNFTMarketV2 public myNFTMarketV2;
    Token public token;
    MyERC721 nft;
    MyNFTMarketProxy marketProxy;

    address marketAdmin;
    address eoaAAA;
    address eoaBBB;

    uint256 aaaPrivateKey;

    function setUp() public {
        aaaPrivateKey = 0xA11CE;

        marketAdmin = makeAddr("marketAdmin");
        eoaAAA = vm.addr(aaaPrivateKey);
        eoaBBB = makeAddr("BBB");

        // eoaOwner = makeAddr("eoa1");
        deal(marketAdmin, 100 ether);
        deal(eoaAAA, 101 ether);
        deal(eoaBBB, 102 ether);

        vm.startPrank(marketAdmin);
        console.log("current pranked=", marketAdmin, "msg.sender=", msg.sender);
        nft = new MyERC721();
        nft.mint(marketAdmin, 1);
        nft.transferFrom(marketAdmin, eoaAAA, 1);

        token = new Token();

        token.transfer(eoaAAA, 3 * 1e18);
        token.transfer(eoaBBB, 3 * 1e18);

        myNFTMarketV1 = new MyNFTMarketV1(address(token), address(nft));

        bytes memory x;
        marketProxy = new MyNFTMarketProxy(address(myNFTMarketV1), x);

        console.log("[ADDRESS]myNFTMarketV1:", address(myNFTMarketV1));
        console.log("[ADDRESS]marketProxy:", address(marketProxy));
        console.log("[ADDRESS]token:", address(token));
        console.log("[ADDRESS]nft:", address(nft));

        myNFTMarketV2 = new MyNFTMarketV2(address(token), address(nft));
        console.log("[ADDRESS]myNFTMarketV2:", address(myNFTMarketV2));

        vm.stopPrank();
    }

    // 代理合约，v1版本，用户上架，b用户购买
    function test_nftBuy_impl() public {
        MyNFTMarketV1 agentAsMarket = MyNFTMarketV1(address(marketProxy));

        vm.startPrank(eoaAAA);
        nft.approve(address(agentAsMarket), 1);
        agentAsMarket.list(1, 1e17);
        vm.stopPrank();

        vm.startPrank(eoaBBB);
        token.approve(address(agentAsMarket), 1e17);
        agentAsMarket.buy(1, 1e17);
        vm.stopPrank();
    }

    // 代理合约，v1版本升级到v2版本. 然后用户离线签名, market根据签名结果为用户上架，b用户购买
    function test_nftBuyV2_impl() public {
        vm.startPrank(marketAdmin);
        console.log("before upgrade:", marketProxy.getImplementation());
        marketProxy.upgradeMarketImpl(address(myNFTMarketV2), "isAdminTask");
        console.log("after upgrade:", marketProxy.getImplementation());

        //
        MyNFTMarketV2 agentAsMarket = MyNFTMarketV2(address(marketProxy));

        vm.startPrank(eoaAAA);
        // AAA账户批量授权给market，然后离线签名指定的一个nft
        nft.setApprovalForAll(address(marketProxy), true);

        MyNFTMarketV2Permit.Permit memory permit = MyNFTMarketV2Permit.Permit({
            owner: address(eoaAAA),
            spender: address(marketProxy),
            tokenId: 1,
            amount: 1e17,
            nonce: 0
        });
        console.log("eoaAAA-----:", eoaAAA);
        bytes32 digest = agentAsMarket.getTypedDataHash(permit);
        console.logBytes32(digest);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(aaaPrivateKey, digest);

        ////
        ////

        assertEq(nft.balanceOf(address(eoaAAA)), 1);
        assertEq(nft.balanceOf(address(marketProxy)), 0);

        // nft市场根据签名结果代替AAA上架
        agentAsMarket.permitList(eoaAAA, 1, 1e17, v, r, s);

        assertEq(nft.balanceOf(address(eoaAAA)), 0);
        assertEq(nft.balanceOf(address(marketProxy)), 1);

        vm.stopPrank();

        // bbb购买.
        vm.startPrank(eoaBBB);
        token.approve(address(agentAsMarket), 1e17);
        agentAsMarket.buy(1, 1e17);
        vm.stopPrank();

        assertEq(nft.balanceOf(address(eoaBBB)), 1);
        assertEq(nft.balanceOf(address(marketProxy)), 0);
        console.log("nft balance, aaa=", nft.balanceOf(address(eoaAAA)));
        console.log("nft balance, bbb=", nft.balanceOf(address(eoaBBB)));
        console.log(
            "nft balance, market=",
            nft.balanceOf(address(agentAsMarket))
        );
    }
}
