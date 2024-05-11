// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/*
编写一个 TokenBank 合约，可以将自己的 Token 存入到 TokenBank， 和从 TokenBank 取出。

TokenBank 有两个方法：

deposit() : 需要记录每个地址的存入数量；
withdraw（）: 用户可以提取自己的之前存入的 token。
在回答框内输入你的代码或者 github 链接。

*/

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import "./MyERC20.sol";

contract TokenBank {
    ERC20 public immutable token;

    // 账户的地址、 账户对应的token余额
    mapping(address => uint256) public userBalances;

    // 排序的存款前10用户.
    mapping(address => address) public orderedTop10Users;
    address constant GUARD = address(1);
    uint256 public listSize;
    uint256 constant topSizeMax = 10;

    // 记录第11名的"最高金额"，凡是有用户余额减少后低于该值，则不会进入top10
    // 所以当有用户退出top10之后，top10的用户数量可能会低于10个。
    uint256 balance11;

    constructor(address _tokenCa) {
        token = ERC20(_tokenCa);
        orderedTop10Users[GUARD] = GUARD;
    }

    /** 指定代币地址与金额，向银行存入该代币.
     */
    function deposit(uint256 _value) public {
        token.transferFrom(msg.sender, address(this), _value);
        userBalances[msg.sender] += _value;
        _frontTop10(msg.sender);
    }

    /** 用户从银行提取自己的token
     */
    function withdraw(uint256 _value) public {
        uint256 balance = userBalances[msg.sender];
        require(_value <= balance, "Bank: withdraw amount exceeds balance");

        userBalances[msg.sender] -= _value;
        token.transfer(msg.sender, _value);
    }

    function queryTop10() external view returns (address[10] memory rtnArr) {
        address pt = GUARD;
        uint256 k = 0;
        while (orderedTop10Users[pt] != GUARD) {
            rtnArr[k++] = orderedTop10Users[pt];
            pt = orderedTop10Users[pt];
        }
    }

    // 用户余额增加了，调用本方法判断是否需要进入前10或者往前移动名次
    function _frontTop10(address user) internal {
        if (userBalances[user] <= balance11) {
            return;
        }
        address preUser = _findPreUser(userBalances[user]);
        if (preUser == user) {
            // 说明名次无变化
        } else {
            orderedTop10Users[user] = orderedTop10Users[preUser];
            orderedTop10Users[preUser] = user;
            listSize++;
            if (listSize > topSizeMax) {
                // 将最后一名的金额更新到 balance11 ，然后移除最后一名
                _dropLastUser(preUser);

                listSize--;
            }
        }
    }

    /**
    用户余额减少了，调用本方法判断是否需要退出前10或者往后移动名次

    暂不实现.
     */
    // function _behindTop10(address user) internal {
    //     if (userBalances[user] <= balance11) {
    //         // 直接删除;
    //     }
    // }

    /**
    从top10 链表中删除最后一名，同时更新 balance11
    @param ptUser 遍历的起始元素 , 且不应该是最后一个元素
     */
    function _dropLastUser(address ptUser) internal {
        address pt1User = ptUser;
        address pt2User = orderedTop10Users[pt1User];
        while (true) {
            if (orderedTop10Users[pt2User] == GUARD) {
                orderedTop10Users[pt1User] = GUARD;
                balance11 = userBalances[pt2User] > balance11
                    ? userBalances[pt2User]
                    : balance11;
                orderedTop10Users[pt2User] = address(0);
                break;
            } else {
                pt1User = pt2User;
                pt2User = orderedTop10Users[pt1User];
            }
        }
    }
    /**
     * 根据余额找出排在该值前面的用户
     */
    function _findPreUser(uint256 balance) internal view returns (address) {
        address preUser = GUARD;
        while (true) {
            address afterUser = orderedTop10Users[preUser];
            if (afterUser == GUARD || balance > userBalances[afterUser]) {
                return preUser;
            }
            preUser = afterUser;
        }
        return preUser;
    }
}
