// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

/// @title ERC-721非同质化代币标准, 可选元信息扩展
/// @dev See https://learnblockchain.cn/docs/eips/eip-721.html
///  Note: 按 ERC-165 标准，接口id为  0x5b5e139f.
/* is ERC721 */ interface IERC721Metadata {
    /// @notice NFTs 集合的名字
    function name() external view returns (string calldata _name);

    /// @notice NFTs 缩写代号
    function symbol() external view returns (string calldata _symbol);

    /// @notice 一个给定资产的唯一的统一资源标识符(URI)
    /// @dev 如果 `_tokenId` 无效，抛出异常. URIs在 RFC 3986 定义，
    /// URI 也许指向一个 符合 "ERC721 元数据 JSON Schema" 的 JSON 文件
    function tokenURI(uint256 _tokenId) external view returns (string calldata);
}
