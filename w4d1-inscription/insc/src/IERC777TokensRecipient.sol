// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IERC777TokensRecipient {
    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes calldata data
    ) external returns (bytes4 retval);
}
