// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：

deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
在回答框内输入你的代码或者 github 链接。

*/

import "./BaseERC20.sol";

contract TokenBank {
    // 可以处理多种token
    // token的地址、 账户的地址、 账户对应的token余额
    mapping(address => mapping(address => uint256)) public userTokenBalances;

    constructor() {}

    /** 指定代币地址与金额，向银行存入该代币.
     */
    function deposit(address token, uint256 _value) public {
        BaseERC20 erc20 = BaseERC20(token);
        erc20.transferFrom(msg.sender, address(this), _value);
        userTokenBalances[token][msg.sender] += _value;
    }

    /** 用户从银行提取自己的token
     */
    function withdraw(address token, uint256 _value) public {
        uint256 balance = userTokenBalances[token][msg.sender];
        require(_value <= balance, "Bank: withdraw amount exceeds balance");

        BaseERC20 erc20 = BaseERC20(token);

        userTokenBalances[token][msg.sender] -= _value;
        erc20.transfer(address(msg.sender), _value);
    }
}
