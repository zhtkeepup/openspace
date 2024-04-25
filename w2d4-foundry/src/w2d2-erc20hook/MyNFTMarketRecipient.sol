// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "../w2d2-nft/MyNFTMarket.sol";
import "./IERC777TokensRecipient.sol";

contract MyNFTMarketRecipient is MyNFTMarket, IERC777TokensRecipient {
    constructor(
        address _token,
        address _nftToken
    ) MyNFTMarket(_token, _nftToken) {}

    error MyNFTMarketNotTransferToMe();
    error MyNFTMarketForbidden();

    function tokensReceived(
        address from,
        address to,
        uint256 amount,
        bytes calldata data /*传入data格式，uint256 tokenId */
    ) external override returns (bytes4 retval) {
        if (address(msg.sender) != token) {
            revert MyNFTMarketForbidden();
        }

        // 当前方法被代币合约回调，说明已经收到了代币，这里需要将指定的nft转移给买主，但无需再调用代币合约的transferFrom
        // (uint256 _num, string memory _name, bytes32 _hash) = abi.decode(_data, (uint256, string, bytes32));
        uint256 tokenId = abi.decode(data, (uint256));
        require(amount >= tokenIdPrice[tokenId], "low price");

        require(
            IERC721(nftToken).ownerOf(tokenId) == address(this),
            "aleady selled"
        );

        IERC721(nftToken).transferFrom(address(this), from, tokenId);

        retval = IERC777TokensRecipient.tokensReceived.selector;
    }
}
