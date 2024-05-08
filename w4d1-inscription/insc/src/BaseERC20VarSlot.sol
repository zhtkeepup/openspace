// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

// 合约最小化。ERC20基本变量槽位。
abstract contract BaseERC20VarSlot {
    address public implementation; // 具体的实现合约
    address public factory; // 工厂合约
    bool public inited; // 是否初始化

    string public name;
    string public symbol;
    uint8 public constant decimals = 18;
    uint256 public totalSupply;
    uint256 public perMint;
    uint256 public price;

    mapping(address => uint256) internal balances;
    mapping(address => mapping(address => uint256)) internal allowances;

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function balanceOf(address _owner) public view returns (uint256 balance) {
        // write your code here
        return balances[_owner];
    }

    function allowance(
        address _owner,
        address _spender
    ) public view returns (uint256 remaining) {
        // write your code here
        return allowances[_owner][_spender];
    }

    // 查询获取mint需要的费用,单位: wei
    function mintChargeInWei() public view returns (uint256) {
        return (perMint / (1e18)) * price;
    }
}
