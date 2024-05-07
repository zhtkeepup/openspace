// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";

import {MyERC721} from "../src/nft/MyERC721.sol";

import {MyERC20With2612Permit as Token} from "../src/MyERC20With2612Permit.sol";

import {MyNFTMarketProxy} from "../src/MyNFTMarketProxy.sol";
import {MyNFTMarketV1} from "../src/MyNFTMarketV1.sol";
import {MyNFTMarketV2} from "../src/MyNFTMarketV2.sol";

// forge script script/DeployTokenNft.s.sol:DeployTokenNft --rpc-url sepolia --private-key $PRIVATE_KEY --broadcast

contract DeployTokenNft is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();
        // Deploy the ERC-20 token
        Token token = new Token();
        MyERC721 nft = new MyERC721();
        // Stop broadcasting calls from our address
        vm.stopBroadcast();
        // Log the token address
        console.log("ERC20 Token Address:", address(token));
        console.log("ERC721 NFT Address:", address(nft));

        /*
  ERC20 Token Address: 0xee36856865c6792ACE7310Bd10DDf80492922175
  ERC721 NFT Address: 0x334752232938E060755e2CeCe44D1664ca61d873
        */
    }
}
