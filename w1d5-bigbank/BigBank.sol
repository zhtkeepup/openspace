/**
 * 题目#1
编写一个 BigBank 合约， 它继承自  Bank 合约，并实现功能：

要求存款金额 >0.001 ether（用modifier权限控制）
BigBank 合约支持转移管理员
同时编写一个 Ownable 合约，把 BigBank 的管理员转移给Ownable 合约， 实现只有Ownable 可以调用 BigBank 的 withdraw().
编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
用数组记录存款金额的前 3 名用户
请提交完成项目代码或 github 仓库地址。
 */

// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import "./Bank.sol";
import "./Ownable.sol";

contract BigBank is Bank {
    error NeedMoreThan0_001Eth();

    error OwnableIsCreated();

    event CreateOwnable(
        address indexed bigBankAddress,
        address eoaAddress,
        address ownableAddress
    );

    address public ownable = address(0);

    modifier amountRequire() {
        if (msg.value <= 1e15) revert NeedMoreThan0_001Eth();
        _;
    }

    function updateTopThree() public payable override amountRequire {
        super.updateTopThree();
    }

    function createOwnable() public returns (address) {
        // address _eoaOwner, address _bigBank
        if (ownable != address(0)) revert OwnableIsCreated();

        ownable = address(new Ownable(msg.sender, address(this)));
        setAdmin(ownable);
        emit CreateOwnable(address(this), msg.sender, ownable);
        return ownable;
    }
}
