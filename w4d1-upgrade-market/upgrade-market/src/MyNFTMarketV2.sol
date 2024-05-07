// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MyNFTMarketV1.sol";
import "./nft/MyERC721.sol";

import "./MyNFTMarketV2Permit.sol";

contract MyNFTMarketV2 is MyNFTMarketV1, MyNFTMarketV2Permit {
    constructor(
        address _token,
        address _nftToken
    ) MyNFTMarketV1(_token, _nftToken) {
        //
    }

    event marketAddr(string, bytes32);
    //
    function permitList(
        address owner,
        uint256 tokenId,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        // bytes32 structHash = keccak256(
        //     abi.encode(
        //         PERMIT_TYPEHASH,
        //         owner,
        //         address(this),
        //         tokenId,
        //         amount,
        //         _useNonce(owner)
        //     )
        // );

        // bytes32 hash = _hashTypedDataV4(structHash);
        // emit marketAddr("123====addr:", hash);
        Permit memory permit = Permit({
            owner: owner,
            spender: address(this),
            tokenId: tokenId,
            amount: amount,
            nonce: _useNonce(owner)
        });
        bytes32 digest = getTypedDataHash(permit);

        address signer = ECDSA_recover(digest, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        _listFrom(owner, tokenId, amount);
    }

    function _listFrom(address owner, uint tokenId, uint amount) internal {
        IERC721(nftToken).safeTransferFrom(owner, address(this), tokenId, "");
        tokenIdPrice[tokenId] = amount;
        tokenSeller[tokenId] = msg.sender;
    }
}
