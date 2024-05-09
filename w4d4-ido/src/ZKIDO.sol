// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

contract ZKIDO {
    address public immutable erc20Ca; // 需要预售的代币合约
    uint256 public immutable presalePrice; // 预售价格(wei/个)
    uint256 public immutable softcap; // 募资ETH最低目标
    uint256 public immutable hardcap; // 硬顶，目标上限
    uint256 public immutable endTimestamp; // 截止时间

    address public immutable admin;

    uint256 public immutable presaleTotal; // 预售总量(根据硬顶与价格计算)

    uint256 public presaleCap; // 预售期间募资的ETH

    // 记录预售时每个地址提供的金额
    mapping(address => uint256) public presaleEthAmounts;

    bool private _enable = false;

    bool private _withdraw = false;

    uint256 public constant token_1e18 = 1e18;

    event Claim(address, uint256, uint256);

    event Refund(address, uint256);

    event Withdraw(address, uint256, uint256);

    modifier onlyAdmin() {
        require(admin == msg.sender, "only admin!");
        _;
    }

    modifier requireEnabled() {
        require(_enable, "should be enable before!");
        _;
    }

    // 并不是所有的ERC20有相应的mint方法。
    // 这里要求合约创建之后， 然后将代币的“待预售量” 转给 当前 IDO 合约地址（用于后续预售），
    // 然后调用 enable() 启用

    constructor(
        address _erc20Ca,
        uint256 _presalePrice, // 价格(wei/个)
        uint256 _softcap, // 软顶 ETH-wei
        uint256 _hardcap, // 硬顶 ETH-wei
        uint256 _lifetimeInDay // 预售时长(天)
    ) {
        admin = msg.sender;

        erc20Ca = _erc20Ca;
        presalePrice = _presalePrice;
        softcap = _softcap;
        hardcap = _hardcap;
        endTimestamp = block.timestamp + _lifetimeInDay * 24 * 3600;

        // 硬顶总金额对应的数量，应该是预售最大总量. (wei)
        presaleTotal = (token_1e18 * hardcap) / presalePrice;
    }

    error ErrorPresaleAmount(uint256, uint256);
    // 校验预售量并启用
    function enable(uint256 presaleAmount) public onlyAdmin {
        require(!_enable, "has enabled!");

        ERC20 erc20 = ERC20(erc20Ca);
        if (
            erc20.balanceOf(address(this)) >= presaleAmount &&
            presaleTotal == presaleAmount
        ) {} else {
            revert ErrorPresaleAmount(presaleAmount, presaleTotal);
        }

        _enable = true;
    }

    // @param amount 需要预购买的数量
    function preSale(uint256 amount) external payable requireEnabled {
        require(block.timestamp <= endTimestamp, "time end!");
        require(
            msg.value == (amount * presalePrice) / token_1e18,
            "not enough ETH"
        );
        presaleEthAmounts[msg.sender] += msg.value;
        presaleCap += msg.value;
    }

    function claim() external {
        require(block.timestamp > endTimestamp, "not begin!");
        require(presaleCap >= softcap, "soft cap havn't reached!");
        require(presaleEthAmounts[msg.sender] > 0, "no share!");

        uint256 preAmount = (token_1e18 * presaleEthAmounts[msg.sender]) /
            presalePrice; // 结果中将 "个" 转换成精度18对应的整数
        uint256 rrAmount; // 实际可得
        if (presaleCap <= hardcap) {
            // 如果低于硬顶，按实际购买领取
            rrAmount = preAmount;
        } else {
            // 如果高于硬顶，则按份额比例计算可以购买的量，多余资金退回
            rrAmount = (preAmount * hardcap) / presaleCap;
        }
        uint256 backAmount = preAmount - rrAmount; // 需要退回的量

        ERC20(erc20Ca).transfer(msg.sender, rrAmount);
        if (backAmount > 0) {
            msg.sender.call{value: (backAmount * presalePrice) / token_1e18}(
                ""
            );
        }
        presaleEthAmounts[msg.sender] = 0;

        emit Claim(msg.sender, preAmount, rrAmount);
    }

    function refund() external {
        require(block.timestamp > endTimestamp, "not begin!");
        require(presaleCap < softcap, "soft cap has reached, can't refund!");

        require(presaleEthAmounts[msg.sender] > 0, "no share!");

        msg.sender.call{value: presaleEthAmounts[msg.sender]}("");

        emit Refund(msg.sender, presaleEthAmounts[msg.sender]);

        presaleEthAmounts[msg.sender] = 0;
    }

    function withdraw() external onlyAdmin {
        require(block.timestamp > endTimestamp, "not begin!");
        require(presaleCap >= softcap, "soft cap havn't reached!");
        require(!_withdraw, "has withdrawn!");

        uint256 withdrawAmount;

        if (presaleCap <= hardcap) {
            // 如果低于硬顶，则全部提取
            withdrawAmount = address(this).balance;
        } else {
            // 如果高于硬顶，只提取硬顶部分.
            withdrawAmount = hardcap;
        }

        msg.sender.call{value: withdrawAmount}("");

        _withdraw = true;

        emit Withdraw(msg.sender, presaleCap, withdrawAmount);
    }
}
