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

contract DeployMyNFTMarketV1 is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();
        // Deploy the ERC-20 token
        MyNFTMarketV1 mm = new MyNFTMarketV1(
            0xee36856865c6792ACE7310Bd10DDf80492922175,
            0x334752232938E060755e2CeCe44D1664ca61d873
        );
        // Stop broadcasting calls from our address
        vm.stopBroadcast();
        // Log the token address
        console.log("MyNFTMarketV1 Address:", address(mm));

        /*
            MyNFTMarketV1 Address: 0xf29950670259A43C1F3C6D25317980340Bce8aAc
        */
    }
}
