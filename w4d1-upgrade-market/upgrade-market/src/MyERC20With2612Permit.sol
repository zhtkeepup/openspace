//SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/utils/Address.sol";
// import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "../lib/openzeppelin-contracts/contracts/token/ERC20/extensions/ERC20Permit.sol";

interface TokenRecipient {
    function tokensReceived(
        address sender,
        uint amount
    ) external returns (bool);
}

contract MyERC20With2612Permit is ERC20Permit {
    using Address for address;

    constructor() ERC20("ZK1token", "ZK1") ERC20Permit("ERC2612") {
        _mint(msg.sender, 10000_0000 * 10 ** 18);
    }

    function transferWithCallback(
        address recipient,
        uint256 amount
    ) external returns (bool) {
        _transfer(msg.sender, recipient, amount);

        if (recipient.code.length > 0) {
            bool rv = TokenRecipient(recipient).tokensReceived(
                msg.sender,
                amount
            );
            require(rv, "No tokensReceived");
        }

        return true;
    }
}
