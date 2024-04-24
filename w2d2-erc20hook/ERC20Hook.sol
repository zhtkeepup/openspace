// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./BaseERC20.sol";

import "./IERC777TokensRecipient.sol";

contract ERC20hook is BaseERC20 {
    error ERC20CallbackNotExists(address);
    error ERC20CallbackNotExists2(address, bytes);

    function transferWithCallback(
        address _to,
        uint256 _value,
        bytes calldata data
    ) public returns (bool success) {
        bool rtn = transfer(_to, _value);
        if (!rtn) {
            return rtn;
        }

        if (_to.code.length > 0) {
            try
                IERC777TokensRecipient(_to).tokensReceived(
                    msg.sender,
                    _to,
                    _value,
                    data
                )
            returns (bytes4 retval) {
                if (retval != IERC777TokensRecipient.tokensReceived.selector) {
                    // Token rejected
                    revert ERC20CallbackNotExists(_to);
                }
            } catch (bytes memory reason) {
                revert ERC20CallbackNotExists2(_to, reason);
            }
        }
        return rtn;
    }
}
