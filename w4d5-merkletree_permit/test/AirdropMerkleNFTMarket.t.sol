// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "../lib/forge-std/src/Test.sol";
import {AirdropMerkleNFTMarket} from "../src/AirdropMerkleNFTMarket.sol";
import {MyERC20With2612Permit} from "../src/MyERC20With2612Permit.sol";
import {MyERC721} from "../src/nft/MyERC721.sol";
import {SigUtils} from "../src/SigUtils.sol";

contract AirdropMerkleNFTMarketTest is Test {
    MyERC721 public nft;
    MyERC20With2612Permit public token;

    AirdropMerkleNFTMarket public market;

    address mmAdmin;
    address eoaAAA;
    address eoaBBB;
    address eoaCCC;
    address eoa444;

    uint256 bbbPrivateKey = 0x123456;

    SigUtils sigUtils;

    function setUp() public {
        //

        /*
  "0x0000000000000000000000000000000000AaA111",
  "0x0000000000000000000000000000000000bBb222",
  "0x0000000000000000000000000000000000CCC333",
*/

        mmAdmin = address(0xAD888); // makeAddr("mmAdmin");
        eoaAAA = address(0xAAA111); //
        eoaBBB = vm.addr(bbbPrivateKey); //makeAddr("BBB");
        eoaCCC = address(0xccc333);
        eoa444 = address(0xddd444);

        console.log("address1:", eoaAAA);
        console.log("address2:", eoaBBB);
        console.log("address3:", eoaCCC);

        vm.startPrank(mmAdmin);

        nft = new MyERC721();
        token = new MyERC20With2612Permit();
        market = new AirdropMerkleNFTMarket(address(token), address(nft));

        sigUtils = new SigUtils(token.DOMAIN_SEPARATOR());

        nft.mint(eoaAAA, 1);

        token.transfer(eoaAAA, 101 * 1e18);
        token.transfer(eoaBBB, 102 * 1e18);
        token.transfer(eoaCCC, 103 * 1e18);

        // eoaOwner = makeAddr("eoa1");
        deal(mmAdmin, 100 ether);
        deal(eoaAAA, 101 ether);
        deal(eoaBBB, 102 ether);
        deal(eoaCCC, 103 ether);

        vm.stopPrank();
    }

    function test_airdrop() public {
        // // 1. BBB用户生成授权给market的离线签名
        vm.startPrank(eoaBBB);
        uint256 _deadline = block.timestamp + 3600 * 24;
        SigUtils.Permit memory permit = SigUtils.Permit({
            owner: eoaBBB,
            spender: address(market), // 通过签名授权给银行
            value: 10 * 1e18,
            nonce: 0,
            deadline: _deadline
        });
        // eoa在链下签名
        bytes32 digest = sigUtils.getTypedDataHash(permit);
        (uint8 v, bytes32 r, bytes32 s) = vm.sign(bbbPrivateKey, digest);

        ////

        // // 2. eoaAAA用户在市场上架NFT。 后续，BBB用户购买，属于白名单，应该以挂单价的一半成交.
        uint256 nftId = 1;
        uint256 price = 1e17;

        vm.startPrank(eoaAAA);
        nft.approve(address(market), nftId);
        market.list(nftId, price);

        // string[] memory cmds = new string[](2);
        // cmds[0] = "node";
        // cmds[1] = "javascript/src/whitelist-merkletree.js";

        // console.logBytes(vm.ffi(cmds));

        // // 3. B用户 购买。
        vm.startPrank(eoaBBB);

        // fff_normal(_deadline, v, r, s, nftId, price);

        fff_multicall(_deadline, v, r, s, nftId, price);
    }

    function fff_multicall(
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 nftId,
        uint256 price
    ) public {
        uint256 tokenBalance1 = token.balanceOf(eoaBBB);
        uint256 nftBalance1 = nft.balanceOf(eoaBBB);

        bytes[] memory calldatas = new bytes[](2);
        calldatas[0] = abi.encodeCall(
            market.permitPrePay,
            (eoaBBB, 10 * 1e18, _deadline, v, r, s)
        );

        bytes32[] memory _merkleProof = new bytes32[](1);

        // 由链下系统读取的merkle proof， 这里直接固定赋值.
        _merkleProof[
            0
        ] = 0xb77cd6e78250fc179507e63db4a067bf94a54f7c43da7c04744a20c4b8833aeb;

        calldatas[1] = abi.encodeCall(
            market.claimNFT,
            (nftId, price / 2, _merkleProof)
        );

        /////

        bytes[] memory results = market.multicall(calldatas);
        assertEq(results[0], "");
        assertEq(results[1], "");

        uint256 tokenBalance2 = token.balanceOf(eoaBBB);
        uint256 nftBalance2 = nft.balanceOf(eoaBBB);

        console.log("multi-bal1: ", tokenBalance1, nftBalance1);
        console.log("multi-bal2: ", tokenBalance2, nftBalance2);
        console.log("multi-price", price, tokenBalance1 - tokenBalance2);

        assertEq(nftBalance2 - nftBalance1, 1);
        assertEq(tokenBalance1 - tokenBalance2, price / 2);
    }

    function fff_normal(
        uint256 _deadline,
        uint8 v,
        bytes32 r,
        bytes32 s,
        uint256 nftId,
        uint256 price
    ) public {
        // 首先使用离线签名，将BBB的token授权给market
        console.log(
            "before permitPrePay:",
            token.allowance(eoaBBB, address(market))
        );
        market.permitPrePay(eoaBBB, 10 * 1e18, _deadline, v, r, s);
        console.log(
            "after permitPrePay:",
            token.allowance(eoaBBB, address(market))
        );

        ////
        uint256 tokenBalance1 = token.balanceOf(eoaBBB);
        uint256 nftBalance1 = nft.balanceOf(eoaBBB);

        bytes32[] memory _merkleProof = new bytes32[](1);

        // 由链下系统读取的merkle proof， 这里直接固定赋值.
        _merkleProof[
            0
        ] = 0xb77cd6e78250fc179507e63db4a067bf94a54f7c43da7c04744a20c4b8833aeb;

        // _merkleProof[
        //     1
        // ] = 0xf84943292c1035f8068f4c9e0c9c43e1ab4d97bea157d677a3510858cdeae4aa;
        market.claimNFT(nftId, price / 2, _merkleProof);

        uint256 tokenBalance2 = token.balanceOf(eoaBBB);
        uint256 nftBalance2 = nft.balanceOf(eoaBBB);

        console.log("bal1: ", tokenBalance1, nftBalance1);
        console.log("bal2: ", tokenBalance2, nftBalance2);
        console.log("price", price, tokenBalance1 - tokenBalance2);

        assertEq(nftBalance2 - nftBalance1, 1);
        assertEq(tokenBalance1 - tokenBalance2, price / 2);
    }
}
