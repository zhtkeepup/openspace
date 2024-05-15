// SPDX-License-Identifier: GPL-3.0-or-later

// pragma solidity >=0.5.0;
pragma solidity =0.8.20;

import "../libraries/AddressStringUtil.sol";

contract AddressStringUtilTest {
    function toAsciiString(
        address addr,
        uint256 len
    ) external pure returns (string memory) {
        return AddressStringUtil.toAsciiString(addr, len);
    }
}
