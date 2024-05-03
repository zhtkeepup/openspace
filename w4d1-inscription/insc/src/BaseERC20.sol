// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./BaseERC20VarSlot.sol";

contract BaseERC20 is BaseERC20VarSlot {
    constructor() {
        // write your code here
        // set name,symbol,decimals,totalSupply
        // name = "BaseERC20";
        // symbol = "BERC20";
        // totalSupply = 100000000 * (1e18);
        // balances[msg.sender] = totalSupply;
    }

    function transfer(
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here

        require(
            balances[msg.sender] >= _value,
            "ERC20: transfer amount exceeds balance"
        );

        balances[msg.sender] -= _value;
        balances[_to] += _value;

        emit Transfer(msg.sender, _to, _value);
        return true;
    }

    function transferFrom(
        address _from,
        address _to,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        require(
            balances[_from] >= _value,
            "ERC20: transfer amount exceeds balance"
        );
        require(
            allowances[_from][msg.sender] >= _value,
            "ERC20: transfer amount exceeds allowance"
        );

        balances[_from] -= _value;
        balances[_to] += _value;

        allowances[_from][msg.sender] -= _value;

        emit Transfer(_from, _to, _value);
        return true;
    }

    function approve(
        address _spender,
        uint256 _value
    ) public returns (bool success) {
        // write your code here
        // mapping(address => mapping(address => uint256)) allowances;
        mapping(address => uint256) storage aa = allowances[msg.sender];
        aa[_spender] = _value;

        emit Approval(msg.sender, _spender, _value);
        return true;
    }
}
