// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// import {ERC20} from "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    address admin;

    constructor(
        string memory symbol,
        uint256 _totalSupply
    ) ERC20(symbol, symbol) {
        admin = msg.sender;
        _mint(msg.sender, _totalSupply * 1e18);
    }
}
