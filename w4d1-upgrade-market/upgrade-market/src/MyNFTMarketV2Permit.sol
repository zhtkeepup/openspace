// SPDX-License-Identifier: MIT

// pragma solidity ^0.4.20;

pragma solidity ^0.8.0;

import {EIP712} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/EIP712.sol";
import {Nonces} from "../lib/openzeppelin-contracts/contracts/utils/Nonces.sol";
import {ECDSA} from "../lib/openzeppelin-contracts/contracts/utils/cryptography/ECDSA.sol";

contract MyNFTMarketV2Permit is EIP712("MyNFTMarketV2", "1"), Nonces {
    struct Permit {
        address owner;
        address spender;
        uint256 tokenId;
        uint256 amount;
        uint256 nonce;
    }

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256(
            "permit(address owner,address spender,uint256 tokenId,uint256 amount,uint256 nonce)"
        );

    error ERC2612InvalidSigner(address signer, address owner);

    function ECDSA_recover(
        bytes32 hash,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) internal pure returns (address) {
        return ECDSA.recover(hash, v, r, s);
    }

    function DOMAIN_SEPARATOR() public view returns (bytes32) {
        return _domainSeparatorV4();
    }

    function getStructHash(
        Permit memory _permit
    ) internal pure returns (bytes32) {
        return
            keccak256(
                abi.encode(
                    PERMIT_TYPEHASH,
                    _permit.owner,
                    _permit.spender,
                    _permit.tokenId,
                    _permit.amount,
                    _permit.nonce
                )
            );
    }

    function getTypedDataHash(
        Permit memory _permit
    ) public view returns (bytes32) {
        return
            keccak256(
                abi.encodePacked(
                    "\x19\x01",
                    DOMAIN_SEPARATOR(),
                    getStructHash(_permit)
                )
            );
    }
}
