//SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "./ERC20Hook.sol";

contract MyERC20InscImpl is ERC20Hook {
    // using Address for address;

    error ErrorYouAreNotFactory(address);
    error ErrorHadInitialized(address);

    modifier onlyFactory() {
        if (msg.sender != factory) {
            revert ErrorYouAreNotFactory(msg.sender);
        }
        _;
    }
    constructor(address _factory) {
        // _mint(msg.sender, 1000 * 10 ** 18);
        factory = _factory;
        inited = true; // “实现合约”本身，没必要再被调用 initDeploy
    }

    function initDeploy(
        string calldata _symbol,
        uint256 _totalSupply,
        uint256 _perMint,
        uint256 _price
    ) public onlyFactory {
        if (inited) {
            revert ErrorHadInitialized(address(this));
        }
        name = _symbol;
        symbol = _symbol;
        perMint = _perMint * (1e18);
        price = _price;

        // 初始部署时，直接将总量赋给当前合约本身
        totalSupply = _totalSupply * (1e18); // 100000000 * (1e18);
        balances[address(this)] = totalSupply;

        inited = true;
    }

    function mintInscription(
        address _to,
        uint256 mintCost // 用户mint时需要的铸造费用。在factory里已经转账，这里判断一下是否足额
    ) public onlyFactory returns (bool) {
        // write your code here
        require(mintCost >= price * (perMint / (1e18)), "cost too small 222");
        require(
            balances[address(this)] - perMint >= 0,
            "Inscription Mint finished!"
        );

        balances[address(this)] -= perMint;
        balances[_to] += perMint;

        // mint时 事件中，from写0
        emit Transfer(address(0), _to, perMint);
        return true;
    }
}
