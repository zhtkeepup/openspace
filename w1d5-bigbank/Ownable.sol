/**
 Ownable 合约.
把 BigBank 的管理员转移给Ownable 合约， 实现只有Ownable 可以调用 BigBank 的 withdraw().
编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "./BigBank.sol";

contract Ownable {
    // 外部可以调用当前合约的eoa地址
    address public eoaOnwer;

    // 被当前合约控制的 bigBank合约的地址
    address public bigBank;

    modifier onlyOwner() {
        require(msg.sender == eoaOnwer, "Only Onwer can call this function.");
        _;
    }

    constructor(address _eoaOwner, address _bigBank) {
        eoaOnwer = _eoaOwner;
        bigBank = _bigBank;
    }

    function bigBankWithdraw(uint256 amount) public payable onlyOwner {
        BigBank(payable(bigBank)).withdraw(amount, msg.sender);
    }
}
