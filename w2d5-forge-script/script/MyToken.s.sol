// SPDX-License-Identifier: MIT
pragma solidity 0.8.25;

// import {Script, console} from "forge-std/Script.sol";

import "forge-std/Script.sol";
import "../src/MyToken.sol";

// forge script script/MyToken.s.sol:MyScript --rpc-url $SEPOLIA_RPC_URL --broadcast --verify -vvvv

contract MyScript is Script {
    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        vm.startBroadcast(deployerPrivateKey);

        // name_, symbol_
        MyToken myToken = new MyToken("ZK01", "ZK01Token");

        vm.stopBroadcast();
    }
}
