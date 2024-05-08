// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {MessageHashUtils} from "@openzeppelin/contracts/utils/cryptography/MessageHashUtils.sol";

library MarketWhitelistPermitLib {
    bytes32 internal constant PERMIT_TYPEHASH =
        keccak256("PermitWhite(address admin,address whiteUser,uint256 nonce)");

    struct Permit {
        address admin;
        address whiteUser;
        uint256 nonce;
    }

    // computes the hash of a permit
    function getStructHash(
        Permit memory _permit
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.admin,
                    _permit.whiteUser,
                    _permit.nonce
                )
            );
    }

    // computes the hash of the fully encoded EIP-712 message for the domain, which can be used to recover the signer
    function getTypedDataHash(
        Permit memory _permit,
        bytes32 DOMAIN_SEPARATOR
    ) public pure returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR,
                    getStructHash(_permit)
                )
            );
    }

    // 这个返回值应该和上面的 getTypedDataHash 一样
    function getTypedDataHash2(
        Permit memory _permit,
        bytes32 DOMAIN_SEPARATOR
    ) public pure returns (bytes32) {
        return
            MessageHashUtils.toTypedDataHash(
                DOMAIN_SEPARATOR,
                getStructHash(_permit)
            );
    }
}
