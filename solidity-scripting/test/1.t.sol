

string memory url = vm.rpcUrl("optimism");
assertEq(url, "https://optimism.alchemyapi.io/v2/...");



vm.expectRevert("Failed to resolve env var `${RPC_MAINNET}` in `RPC_MAINNET`: environment variable not found");
string memory url = vm.rpcUrl("mainnet");



string[2][] memory allUrls = vm.rpcUrls();
assertEq(allUrls.length, 2);

string[2] memory val = allUrls[0];
assertEq(val[0], "optimism");

string[2] memory env = allUrls[1];
assertEq(env[0], "mainnet");




// balance at block <https://etherscan.io/block/18332681>
bytes memory result = vm.rpc("eth_getBalance", "[\"0x8D97689C9818892B700e27F316cc3E41e17fBeb9\", \"0x117BC09\"]")
assertEq(hex"10b7c11bcb51e6", result);

