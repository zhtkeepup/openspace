//SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

/*
Counter 合约具有
一个状态变量 counter
get()方法: 获取 counter 的值
add(x) 方法: 给变量加上 x 。
请在回答框内提交调用 add(x) 的交易 Hash 的区块链浏览器的 URL。
*/

// 定义一个合约.
// 2024-04-16 20:17 add方法对应的交易hash：https://sepolia.etherscan.io/tx/0x2c0c981c8ed67d3efe3522a0d8976ab465cc11db27ebe6d541c56ed9bb2cbf44
contract Counter {
    uint public counter;

    constructor() {
        counter = 0;
    }

    function count() public {
        counter = counter + 1;
    }

    function get() public view returns (uint) {
        return counter;
    }

    function add(uint x) external {
        counter = counter + x;
    }
}
