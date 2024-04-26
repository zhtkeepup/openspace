/*
测试对象：TokenHook , TokenBank , NFTMarket, 
*/

// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

// import {Test, console} from "forge-std/Test.sol";

import "forge-std/Test.sol";

import {MyNFTMarketRecipient} from "../src/w2d2-erc20hook/MyNFTMarketRecipient.sol";
import {ERC20hook} from "../src/w2d2-erc20hook/ERC20Hook.sol";
import {MyERC721} from "../src/w2d2-nft/MyERC721.sol";

contract MyNFTMarketRecipientTest is Test {
    MyNFTMarketRecipient nftMarket; //  = new Bank();
    ERC20hook token;
    MyERC721 nftToken;
    address alice;
    address eve;

    function setUp() public {
        alice = makeAddr("alice");
        eve = makeAddr("eve");

        vm.deal(alice, 10 ether);

        token = new ERC20hook();
        nftToken = new MyERC721();
        nftMarket = new MyNFTMarketRecipient(address(token), address(nftToken));

        token.transfer(alice, token.totalSupply() / 6);
        token.transfer(eve, token.totalSupply() / 6);

        console.log("totalSupply:", token.totalSupply());
        console.log("alice bal:", token.balanceOf(alice));

        nftToken.mint(alice, 1);
        nftToken.mint(eve, 2);
        console.log("alice addr:", alice);
        console.log("eve addr:", alice);
        console.log("this addr:", address(this));
        // vm.startPrank(alice);
    }

    function test_list() public {
        uint256 _tokenId = 1;
        vm.startPrank(alice);
        nftToken.approve(address(nftMarket), _tokenId);
        nftMarket.list(_tokenId, 10000);

        assertEq(nftToken.ownerOf(_tokenId), address(nftMarket));

        vm.stopPrank();
    }

    function test_buy() public {
        uint256 _tokenId = 1;
        vm.startPrank(alice);
        nftToken.approve(address(nftMarket), _tokenId);
        nftMarket.list(_tokenId, 10000);

        vm.stopPrank();

        vm.startPrank(eve);

        token.approve(address(nftMarket), 10000);

        nftMarket.buy(_tokenId, 10000);

        assertEq(nftToken.ownerOf(_tokenId), eve);
        vm.stopPrank();
    }
}
