// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.13;

import "../lib/openzeppelin-contracts/contracts/utils/cryptography/MerkleProof.sol";

import "../lib/openzeppelin-contracts/contracts/utils/Multicall.sol";

import "./MyNFTMarketV2.sol";

contract AirdropMerkleNFTMarket is MyNFTMarketV2, Multicall {
    // merkle root node , generated at offChain.

    bytes32 public merkleRoot =
        0x4f76b259648ab5b58dd9b430513aff80be045d543913258f15d2979126bdfb7d; //

    constructor(
        address _tokenAc,
        address _nftTokenAc
    ) MyNFTMarketV2(_tokenAc, _nftTokenAc) {}

    function setMerkleRoot(bytes32 _merkleRoot) public {
        require(msg.sender == admin, "only admin");
        merkleRoot = _merkleRoot;
    }

    /*
        离线签名验证
    */
    function permitPrePay(
        address owner,
        uint256 value,
        uint256 deadline,
        uint8 v,
        bytes32 r,
        bytes32 s
    ) external {
        MyERC20With2612Permit(token).permit(
            owner,
            address(this), // 验证签名，并且给 spender 执行 approve
            value,
            deadline,
            v,
            r,
            s
        );
    }

    event fkMsg(address, bytes32);
    function claimNFT(
        uint256 tokenId,
        uint256 halfPriceAmt,
        bytes32[] calldata _merkleProof
    ) external {
        bytes32 leaf = keccak256(abi.encodePacked(msg.sender));
        emit fkMsg(msg.sender, leaf);
        require(
            MerkleProof.verify(_merkleProof, merkleRoot, leaf),
            "merkle verified error!"
        );

        tokenIdPrice[tokenId] /= 2; // 指定价格的优惠 50% 的Token 来购买 NFT

        buy(tokenId, halfPriceAmt);
    }
}
