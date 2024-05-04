// SPDX-License-Identifier: MIT

pragma solidity ^0.8.13;

import {ECDSA} from "@openzeppelin/contracts/utils/cryptography/ECDSA.sol";
import {EIP712} from "@openzeppelin/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "@openzeppelin/contracts/utils/Nonces.sol";

import {MarketWhitelistPermitLib} from "./MarketWhitelistPermitLib.sol";

abstract contract MarketWhitelistPermit is EIP712, Nonces {
    /**
     * @dev Mismatched signature.
     */
    error ERC2612InvalidSigner(address signer, address owner);

    constructor() EIP712("NF1", "1") {}

    function permitWhite(
        address admin, // 项目方
        address whiteUser,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        bytes32 structHash = MarketWhitelistPermitLib.getStructHash(
            MarketWhitelistPermitLib.Permit({
                admin: admin,
                whiteUser: whiteUser,
                nonce: _useNonce(whiteUser)
            })
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA.recover(hash, v, r, s);
        if (signer != admin) {
            revert ERC2612InvalidSigner(signer, admin);
        }
    }

    /*
     * @inheritdoc
     */
    function nonces(
        address whiteUser
    ) public view virtual override(Nonces) returns (uint256) {
        return super.nonces(whiteUser);
    }

    /*
     * @inheritdoc ermit
     */
    // solhint-disable-next-line func-name-mixedcase
    function DOMAIN_SEPARATOR() external view virtual returns (bytes32) {
        return _domainSeparatorV4();
    }
}
