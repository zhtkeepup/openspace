// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./nft/IERC721TokenReceiver.sol";

import "./nft/IERC721.sol";

import {MyERC20With2612Permit as ERC20} from "./MyERC20With2612Permit.sol";

contract MyNFTMarketV1 is IERC721TokenReceiver {
    mapping(uint => uint) public tokenIdPrice;
    mapping(uint => address) public tokenSeller;
    address public immutable token;
    address public immutable nftToken;
    address public immutable admin; // 项目方

    error CallFunctionError();

    constructor(address _token, address _nftToken) {
        token = _token;
        nftToken = _nftToken;
        admin = msg.sender;
    }

    function onERC721Received(
        address operator,
        address from,
        uint256 tokenId,
        bytes calldata data
    ) external pure override returns (bytes4) {
        return this.onERC721Received.selector;
    }

    // approve(address to, uint256 tokenId) first
    function list(uint tokenID, uint amount) public {
        IERC721(nftToken).safeTransferFrom(
            msg.sender,
            address(this),
            tokenID,
            ""
        );
        tokenIdPrice[tokenID] = amount;
        tokenSeller[tokenID] = msg.sender;
    }

    function buy(uint tokenId, uint amount) public {
        require(amount >= tokenIdPrice[tokenId], "low price");

        require(
            IERC721(nftToken).ownerOf(tokenId) == address(this),
            "aleady selled"
        );

        ERC20(token).transferFrom(
            msg.sender,
            tokenSeller[tokenId],
            tokenIdPrice[tokenId]
        );

        IERC721(nftToken).transferFrom(address(this), msg.sender, tokenId);
    }

    fallback() external {
        revert CallFunctionError();
    }
}
