// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

// 如果合约（应用）要接受NFT的安全转账，则必须实现以下接口。

/// @dev 按 ERC-165 标准，接口id为 0x150b7a02.
interface IERC721TokenReceiver {
    /// @notice 处理接收NFT
    /// @dev ERC721智能合约在`transfer`完成后，在接收这地址上调用这个函数。
    /// 函数可以通过revert 拒绝接收。返回非`0x150b7a02` 也同样是拒绝接收。
    /// 注意: 调用这个函数的 msg.sender是ERC721的合约地址
    /// @param _operator ：调用 `safeTransferFrom` 函数的地址。
    /// @param _from ：之前的NFT拥有者
    /// @param _tokenId ： NFT token id
    /// @param _data ： 附加信息
    /// @return 正确处理时返回 `bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`
    function onERC721Received(
        address _operator,
        address _from,
        uint256 _tokenId,
        bytes calldata _data
    ) external returns (bytes4);
}
