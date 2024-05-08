// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：

deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
在回答框内输入你的代码或者 github 链接。

*/

import {MyERC20With2612Permit as ERC20} from "./MyERC20With2612Permit.sol";

contract TokenBank {
    // 可以处理多种token
    // token的地址、 账户的地址、 账户对应的token余额
    mapping(address => mapping(address => uint256)) public userTokenBalances;

    constructor() {}

    /** 指定代币地址与金额，向银行存入该代币.
     */
    function deposit(address token, uint256 _value) public {
        _deposit(msg.sender, token, _value);
    }

    function _deposit(address user, address token, uint256 _value) internal {
        ERC20 erc20 = ERC20(token);
        erc20.transferFrom(user, address(this), _value);
        userTokenBalances[token][user] += _value;
    }

    /*
     * 第三方传入用户的离线签名，执行授权与存款
     * @param token 需要存入银行的代币合约
     * @param _validTimeInSecond 签名有效时间，(秒)，比如7200秒.
     */
    function permitDeposit(
        address user,
        address token,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        // 验证签名，并在内部执行approve
        // 这个approve操作，会覆盖用户先前已经授权过的金额（如果有的话）
        ERC20(token).permit(user, address(this), value, deadline, v, r, s); // _approve
        _deposit(user, token, value);
    }

    /** 用户从银行提取自己的token
     */
    function withdraw(address token, uint256 _value) public {
        uint256 balance = userTokenBalances[token][msg.sender];
        require(_value <= balance, "Bank: withdraw amount exceeds balance");

        ERC20 erc20 = ERC20(token);

        userTokenBalances[token][msg.sender] -= _value;
        erc20.transfer(address(msg.sender), _value);
    }
}
