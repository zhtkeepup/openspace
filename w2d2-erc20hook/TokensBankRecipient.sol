// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./TokenBank.sol";

import "./IERC777TokensRecipient.sol";

contract TokensBankRecipient is TokenBank, IERC777TokensRecipient {
    error BankNotTransferToMe();

    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes calldata data
    ) external override returns (bytes4 retval) {
        if (to != address(this)) {
            revert BankNotTransferToMe();
        }

        // token的地址、 账户的地址、 账户对应的token余额
        // mapping(address => mapping(address => uint256)) public userTokenBalances;

        // 银行中当前这个代币，当前这个用户的余额，进行累加
        userTokenBalances[address(msg.sender)][from] += amount;

        retval = IERC777TokensRecipient.tokensReceived.selector;
    }
}
