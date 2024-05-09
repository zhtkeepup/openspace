// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract MyERC20 is ERC20 {
    /**
     */
    constructor(uint256 _t_supply) ERC20("ZK20", "ZK20") {
        _update(address(0), msg.sender, _t_supply * 1e18);
    }
}
