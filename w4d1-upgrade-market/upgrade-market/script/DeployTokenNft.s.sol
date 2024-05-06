// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {MyERC721} from "../src/nft/MyERC721.sol";

import {MyERC20With2612Permit as Token} from "../src/MyERC20With2612Permit.sol";

import {MyNFTMarketProxy} from "../src/MyNFTMarketProxy.sol";
import {MyNFTMarketV1} from "../src/MyNFTMarketV1.sol";
import {MyNFTMarketV2} from "../src/MyNFTMarketV2.sol";

import {MyERC721Permit} from "../src/nft/MyERC721Permit.sol";

// forge script script/DeployTokenNft.s.sol:DeployTokenNft --rpc-url sepolia --private-key $PRIVATE_KEY --broadcast

contract DeployTokenNft is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();
        // Deploy the ERC-20 token
        Token token = new Token();
        MyERC721Permit nft = new MyERC721Permit();
        // Stop broadcasting calls from our address
        vm.stopBroadcast();
        // Log the token address
        console.log("ERC20 Token Address:", address(token));
        console.log("ERC721 NFT Address:", address(nft));
    }
}
