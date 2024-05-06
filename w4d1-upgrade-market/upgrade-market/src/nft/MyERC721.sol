// SPDX-License-Identifier: MIT

// pragma solidity ^0.4.20;

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Strings.sol";

import "./IERC165.sol";
import "./IERC721.sol";
import "./IERC721Metadata.sol";

import "./IERC721TokenReceiver.sol";
import "./MyERC721Permit.sol";

// , IERC721Metadata {
contract MyERC721 is IERC165, IERC721, IERC721Metadata, MyERC721Permit {
    error ERC721CanNotBeZeroAddr();
    error ERC721IsNotOwnerOfNFT(uint256, address, address);
    error ERC721TokenIdIsInvalid(uint256);
    error ERC721InvalidReceiver(address);
    error ERC721TokenIdIsExists(uint256);
    error ERC721YouCanNotMint(address);

    string constant _name = "zk1nft";
    string constant _uriTemp1 =
        "https://teal-fancy-flyingfish-942.mypinata.cloud/ipfs/QmZpxuHm7a6gaYjmWGZbj7KtrTgsDUTdYTogEZqEPY21Uc/nft-opensea-meta";
    string constant _uriTemp2 = ".json";

    mapping(address => uint256 balance) balances; // 账户拥有的nft数量
    mapping(uint256 tokenId => address) owners; // nft的拥有人
    mapping(uint256 tokenId => address) tokenApprovals; // nft授权给了谁

    address creator;

    constructor() {
        creator = msg.sender;
    }

    // owner下所有资产是否授权了某一个或多个第三方operator
    mapping(address owner => mapping(address operator => bool))
        private operatorApprovals;

    /// @dev 函数要少于  30,000 gas.
    /// @return 合约实现了 `interfaceID`（不为  0xffffffff）返回`true` ， 否则false.
    function supportsInterface(bytes4 interfaceId) public pure returns (bool) {
        return
            interfaceId == type(IERC165).interfaceId ||
            interfaceId == type(IERC721).interfaceId ||
            interfaceId == type(IERC721Metadata).interfaceId;
    }

    /// @notice 统计所持有的NFTs数量
    /// @dev NFT 不能分配给零地址，查询零地址同样会异常
    /// @param _owner ： 待查地址
    /// @return 返回数量，也许是0
    function balanceOf(address _owner) public view returns (uint256) {
        if (_owner == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }
        return balances[_owner];
    }

    /// @notice 返回所有者
    /// @dev NFT 不能分配给零地址，查询零地址抛出异常
    /// @param _tokenId NFT 的id
    /// @return 返回所有者地址
    function ownerOf(uint256 _tokenId) public view returns (address) {
        address owner = owners[_tokenId];
        if (owner == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }
        return owner;
    }

    /// @notice 将NFT的所有权从一个地址转移到另一个地址
    /// @dev 如果`msg.sender` 不是当前的所有者（或授权者）抛出异常
    /// 如果 `_from` 不是所有者、`_to` 是零地址、`_tokenId` 不是有效id 均抛出异常。
    ///  当转移完成时，函数检查  `_to` 是否是合约，如果是，调用 `_to`的 `onERC721Received` 并且检查返回值是否是 `0x150b7a02` (即：`bytes4(keccak256("onERC721Received(address,address,uint256,bytes)"))`)  如果不是抛出异常。
    /// @param _from ：当前的所有者
    /// @param _to ：新的所有者
    /// @param _tokenId ：要转移的token id.
    /// @param data : 附加额外的参数（没有指定格式），传递给接收者。
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId,
        bytes memory data
    ) public {
        contractSafeCheck(_from, _to, _tokenId, data);
        transferFrom(_from, _to, _tokenId);
    }

    function contractSafeCheck(
        address _from,
        address _to_contract,
        uint256 _tokenId,
        bytes memory data
    ) internal {
        uint256 size;
        assembly {
            size := extcodesize(_to_contract) // if (to.code.length > 0)
        }
        if (size == 0) return;

        try
            IERC721TokenReceiver(_to_contract).onERC721Received(
                msg.sender,
                _from,
                _tokenId,
                data
            )
        returns (bytes4 retval) {
            if (retval != IERC721TokenReceiver.onERC721Received.selector) {
                // Token rejected
                revert ERC721InvalidReceiver(_to_contract);
            }
            // } catch (bytes memory reason) {
        } catch {
            revert ERC721InvalidReceiver(_to_contract);
            // if (reason.length == 0) {
            //     // non-IERC721Receiver implementer
            //     revert IERC721Errors.ERC721InvalidReceiver(to);
            // } else {
            //     /// @solidity memory-safe-assembly
            //     assembly {
            //         revert(add(32, reason), mload(reason))
            //     }
            // }
        }
    }

    /// @notice 将NFT的所有权从一个地址转移到另一个地址，功能同上，不带data参数。
    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) public {
        safeTransferFrom(_from, _to, _tokenId, "");
    }

    function transfer(address _to, uint256 _tokenId) public {
        safeTransferFrom(msg.sender, _to, _tokenId);
    }

    /// @notice 转移所有权 -- 调用者负责确认`_to`是否有能力接收NFTs，否则可能永久丢失。
    /// @dev 如果`msg.sender` 不是当前的所有者（或授权者、操作员）抛出异常
    /// 如果 `_from` 不是所有者、`_to` 是零地址、`_tokenId` 不是有效id 均抛出异常。
    function transferFrom(address _from, address _to, uint256 _tokenId) public {
        address oldOwner = owners[_tokenId];
        if (oldOwner == address(0)) {
            revert ERC721TokenIdIsInvalid(_tokenId);
        }
        if (oldOwner != _from) {
            revert ERC721IsNotOwnerOfNFT(_tokenId, msg.sender, _from);
        }

        if (
            oldOwner != msg.sender &&
            tokenApprovals[_tokenId] != msg.sender &&
            operatorApprovals[_from][msg.sender] != true
        ) {
            revert ERC721IsNotOwnerOfNFT(_tokenId, msg.sender, msg.sender);
        }

        if (_to == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }

        balances[oldOwner] -= 1;
        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(_from, _to, _tokenId);
    }

    /// @notice 更改或确认NFT的授权地址
    /// @dev 零地址表示没有授权的地址。
    ///  如果`msg.sender` 不是当前的所有者或操作员
    /// @param _approved 新授权的控制者
    /// @param _tokenId ： token id
    function approve(address _approved, uint256 _tokenId) public {
        if (_approved == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }
        if (
            owners[_tokenId] != msg.sender &&
            tokenApprovals[_tokenId] != msg.sender
        ) {
            revert ERC721IsNotOwnerOfNFT(_tokenId, msg.sender, msg.sender);
        }
        tokenApprovals[_tokenId] = _approved;

        emit Approval(msg.sender, _approved, _tokenId);
    }

    /// @notice 启用或禁用第三方（操作员）管理 `msg.sender` 所有资产
    /// @dev 触发 ApprovalForAll 事件，合约必须允许每个所有者可以有多个操作员。
    /// @param _operator 要添加到授权操作员列表中的地址
    /// @param _approved True 表示授权, false 表示撤销
    function setApprovalForAll(address _operator, bool _approved) public {
        if (_operator == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }
        operatorApprovals[msg.sender][_operator] = _approved;
        emit ApprovalForAll(msg.sender, _operator, _approved);
    }

    /// @notice 获取单个NFT的授权地址
    /// @dev 如果 `_tokenId` 无效，抛出异常。
    /// @param _tokenId ：  token id
    /// @return 返回授权地址， 零地址表示没有。
    function getApproved(uint256 _tokenId) public view returns (address) {
        if (owners[_tokenId] == address(0)) {
            revert ERC721TokenIdIsInvalid(_tokenId);
        }
        return tokenApprovals[_tokenId];
    }

    /// @notice 查询一个地址是否是另一个地址的授权操作员
    /// @param _owner 所有者
    /// @param _operator 代表所有者的授权操作员
    function isApprovedForAll(
        address _owner,
        address _operator
    ) public view returns (bool) {
        return operatorApprovals[_owner][_operator];
    }

    /// @notice NFTs 集合的名字
    function name() public pure returns (string memory) {
        return _name;
    }

    /// @notice NFTs 缩写代号
    function symbol() external pure returns (string memory) {
        return _name;
    }

    /// @notice 一个给定资产的唯一的统一资源标识符(URI)
    /// @dev 如果 `_tokenId` 无效，抛出异常. URIs在 RFC 3986 定义，
    /// URI 也许指向一个 符合 "ERC721 元数据 JSON Schema" 的 JSON 文件
    function tokenURI(uint256 _tokenId) public pure returns (string memory) {
        // Convert uint256 to string using Strings library
        // string memory numAsString = Strings.toString(_tokenId);

        // Concatenate strings using string concatenation operator
        // string memory result = string(
        //     abi.encodePacked(_uriTemp1, _tokenId, _uriTemp2)
        // );
        return string.concat(_uriTemp1, Strings.toString(_tokenId), _uriTemp2);
    }

    function mint(address _to, uint256 _tokenId) public {
        if (msg.sender != creator) {
            revert ERC721YouCanNotMint(msg.sender);
        }

        if (owners[_tokenId] != address(0)) {
            revert ERC721TokenIdIsExists(_tokenId);
        }
        if (_to == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }

        contractSafeCheck(address(0), _to, _tokenId, "");

        balances[_to] += 1;
        owners[_tokenId] = _to;

        emit Transfer(address(0), _to, _tokenId);
    }

    /* 授权nft市场上架nft
     */
    function permitApprovalForList(
        address owner,
        address spender,
        uint256 tokenId,
        uint256 amount, // 售价
        uint8 v,
        bytes32 r,
        bytes32 s
    ) public virtual {
        bytes32 structHash = keccak256(
            abi.encode(
                PERMIT_TYPEHASH,
                owner,
                spender,
                tokenId,
                amount,
                _useNonce(owner)
            )
        );

        bytes32 hash = _hashTypedDataV4(structHash);

        address signer = ECDSA_recover(hash, v, r, s);
        if (signer != owner) {
            revert ERC2612InvalidSigner(signer, owner);
        }

        if (spender == address(0)) {
            revert ERC721CanNotBeZeroAddr();
        }
        operatorApprovals[owner][spender] = true;
        emit ApprovalForAll(owner, spender, true);
    }
}
