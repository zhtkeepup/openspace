// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import "./IToken.sol";

contract KKToken is IToken, ERC20("KK", "KK") {
    address public admin;
    address public staking;

    constructor() {
        admin = msg.sender;
    }

    function setStaking(address _staking) external {
        require(admin == msg.sender, "only by admin!");
        staking = _staking;
    }

    /**
    限制为 Staking 合约
     */
    function mint(address to, uint256 amount) external {
        require(staking == msg.sender, "only by staking!");
        _mint(to, amount);
    }
}
