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
        // // 2. mmAdmin用户使用离线签名，将BBB的token授权给market
        console.log(
            "before permitPrePay:",
            token.allowance(eoaBBB, address(market))
        );
        vm.startPrank(mmAdmin);
        market.permitPrePay(eoaBBB, 10 * 1e18, _deadline, v, r, s);
        console.log(
            "after permitPrePay:",
            token.allowance(eoaBBB, address(market))
        );

        // // 3. eoaAAA用户在市场上架NFT，然后BBB用户购买，属于白名单，应该以挂单价的一半成交.
        uint256 nftId = 1;
        uint256 price = 1e17;

        vm.startPrank(eoaAAA);
        nft.approve(address(market), nftId);
        market.list(nftId, price);

        // B用户
        string[] memory cmds = new string[](2);
        cmds[0] = "node";
        cmds[1] = "javascript/src/whitelist-merkletree.js";

        bytes32[] memory _merkleProof = new bytes32[](1);

        _merkleProof[0] = bytes32(vm.ffi(cmds));
        console.logBytes32(_merkleProof[0]);
        // 0x756e646566696e65640000000000000000000000000000000000000000000000
        //
        _merkleProof[
            0
        ] = 0x89ab0aac7fd5bddc5a80851c27af374c9ce62114029e525fb41212e79b547d34;
        market.claimNFT(nftId, price / 2, _merkleProof);
        // address loadedAddress = abi.decode(result, (address));
        // market.claimNFT(1, 1, _merkleProof);
    }
}
