// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract EsRnt is ERC20 {
    address public admin;
    /**
     */
    constructor() ERC20("esRNT", "esRNT") {
        // _update(address(0), msg.sender, _t_supply * 1e18);
        admin = msg.sender;
    }

    function mint(address _to, uint256 amount) external {
        require(msg.sender == admin, "only admin!");
        _update(address(0), _to, amount);
    }

    function chgAdmin(address na) external {
        require(msg.sender == admin, "only admin!");
        admin = na;
    }

    function _update(
        address from,
        address to,
        uint256 value
    ) internal override {
        require(from == address(0), "esRNT can't transfer!");

        super._update(from, to, value);
    }
}
