// SPDX-License-Identifier: MIT

// pragma solidity ^0.4.20;

pragma solidity ^0.8.0;

// 每个符合ERC-721的合同都必须实现 ERC721 和 ERC165 接口（受以下“说明”约束）：

interface IERC165 {
    /// @notice 是否合约实现了接口
    /// @param interfaceID  ERC-165定义的接口id
    /// @dev 函数要少于  30,000 gas.
    /// @return 合约实现了 `interfaceID`（不为  0xffffffff）返回`true` ， 否则false.
    function supportsInterface(bytes4 interfaceID) external view returns (bool);
}
