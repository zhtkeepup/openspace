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

contract DeployV2AndUpgradeProxy is Script {
    function run() public {
        // Use address provided in config to broadcast transactions
        vm.startBroadcast();

        MyNFTMarketV2 mm = new MyNFTMarketV2(
            0xee36856865c6792ACE7310Bd10DDf80492922175,
            0x334752232938E060755e2CeCe44D1664ca61d873
        );
        // Log the token address
        console.log("MyNFTMarketV2 Address:", address(mm));

        MyNFTMarketProxy proxy = MyNFTMarketProxy(
            payable(0x8dA33e7a4e06c7fa5a17929B367211426012ebD2)
        );

        console.log("upgradeMarketImpl.... to: ", address(mm));
        proxy.upgradeMarketImpl(address(mm), "isAdminTask");

        /*
  MyNFTMarketV2 Address: 0x13736647e93DaE2ee9c47b8c390a133E9788F76D
  upgradeMarketImpl.... to:  0x13736647e93DaE2ee9c47b8c390a133E9788F76D
*/
        vm.stopBroadcast();
    }
}

/*
Chain 11155111

Estimated gas price: 25.158255286 gwei

Estimated total gas used for script: 667404

Estimated amount required: 0.016790720210897544 ETH
*/
