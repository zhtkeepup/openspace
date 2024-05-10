// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract RntERC20 is ERC20 {
    address public admin;
    /**
     */
    constructor(uint256 _t_supply) ERC20("RNT", "RNT") {
        admin = msg.sender;
        _update(address(0), msg.sender, _t_supply * 1e18);
    }

    function mint(address _to, uint256 amount) external {
        require(msg.sender == admin, "only admin!");
        _update(address(0), _to, amount);
    }

    function chgAdmin(address na) external {
        require(msg.sender == admin, "only admin!");
        admin = na;
    }
}
