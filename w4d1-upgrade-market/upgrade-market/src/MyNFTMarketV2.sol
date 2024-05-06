// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./MyNFTMarketV1.sol";
import "./nft/MyERC721.sol";

contract MyNFTMarketV2 is MyNFTMarketV1 {
    constructor(
        address _token,
        address _nftToken
    ) MyNFTMarketV1(_token, _nftToken) {
        //
    }

    //
    function permitList(
        address owner,
        uint256 tokenId,
        uint256 amount,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public {
        MyERC721(nftToken).permitApprovalForList(
            owner,
            address(this),
            tokenId,
            amount,
            v,
            r,
            s
        );

        list(tokenId, amount);
    }
}
