// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {ERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/ERC20.sol";

import "./IStaking.sol";
import "./KKToken.sol";

contract Staking is IStaking {
    KKToken kk;
    address admin;

    uint128 constant REWARD_DECIMAL = 1e9; // 奖励数量，的精度

    uint256 constant AMOUNT_PER_BLOCK = 10 * REWARD_DECIMAL; // 10 * 1e9. KK Token 是每一个区块产出 10 个
    //
    struct RewardInfo {
        uint128 accuE9rewardsPerETH; // （上次计算时）奖励率的累加值（奖励率：每个以太币每个区块可获取的奖励数量（放大1e9倍））
        uint128 lastUpdateBlock; // 上次计算时的区块编号
        uint128 ethAmount; // (上次计算时)质押的eth数量
    }

    RewardInfo gRewardInfo; // 全局奖励率信息

    struct UserRewardInfo {
        uint128 rewardAmount; // 已计算获得但未领取的奖励
        uint128 accuE9rewardsPerETH; // （上次计算时）奖励率的累加值（奖励率：每个以太币每个区块可获取的奖励数量（放大1e9倍））
        uint128 lastUpdateBlock; // 上次计算时的区块编号
        uint128 ethAmount; // 质押的eth数量
    }

    mapping(address => UserRewardInfo) userRewardInfos;

    event Stake(address, uint256);
    event Unstake(address, uint256);
    event Claim(address, uint256);

    constructor(address _kkAddress) {
        admin = msg.sender;
        kk = KKToken(_kkAddress);

        gRewardInfo = RewardInfo(0, 0, uint128(block.number));
    }

    function updateReward() private {
        gRewardInfo.accuE9rewardsPerETH += uint128(
            ((block.number - gRewardInfo.lastUpdateBlock) *
                (AMOUNT_PER_BLOCK * 1e18)) / gRewardInfo.ethAmount
        ); //
        gRewardInfo.lastUpdateBlock = uint128(block.number);
        gRewardInfo.ethAmount = uint128(address(this).balance);
    }

    function updateUserReward(uint128 newEthAmount, bool doStake) private {
        UserRewardInfo storage ur = userRewardInfos[msg.sender];

        ur.rewardAmount +=
            (ur.ethAmount *
                (gRewardInfo.accuE9rewardsPerETH - ur.accuE9rewardsPerETH)) /
            REWARD_DECIMAL;

        if (newEthAmount > 0) {
            if (doStake) {
                // 质押
                ur.ethAmount += uint128(newEthAmount);
            } else {
                // 解除质押
                ur.ethAmount -= uint128(newEthAmount);
            }
        }

        ur.accuE9rewardsPerETH = gRewardInfo.accuE9rewardsPerETH;
        ur.lastUpdateBlock = gRewardInfo.lastUpdateBlock;
    }

    /**
     * @dev 质押 ETH 到合约
     */
    function stake() external payable {
        require(msg.value > 0, "no ether!");
        require(msg.value < type(uint128).max, "eth overflow!");
        updateReward();
        updateUserReward(uint128(msg.value), true);
        emit Stake(msg.sender, msg.value);
    }

    /**
     * @dev 赎回质押的 ETH
     * @param _amount 赎回数量
     */
    function unstake(uint256 _amount) external {
        require(_amount > 0, "please specified amount!");
        require(_amount < type(uint128).max, "amount overflow!");
        UserRewardInfo storage ur = userRewardInfos[msg.sender];

        require(_amount <= ur.ethAmount, "staked ETH insufficient");

        updateReward();

        uint128 amount = uint128(_amount);

        updateUserReward(amount, false);

        payable(msg.sender).transfer(uint256(amount));

        emit Unstake(msg.sender, uint256(amount));
    }

    /**
     * @dev 领取 KK Token 收益
     */
    function claim() external {
        updateReward();

        updateUserReward(0, false);

        UserRewardInfo storage ur = userRewardInfos[msg.sender];

        if (ur.rewardAmount > 0) {
            uint256 ra = uint256(ur.rewardAmount);
            ur.rewardAmount = 0;
            kk.mint(msg.sender, ra);
            emit Claim(msg.sender, ra);
        }
    }

    /**
     * @dev 获取质押的 ETH 数量
     * @param account 质押账户
     * @return 质押的 ETH 数量
     */
    function balanceOf(address account) external view returns (uint256) {
        return uint256(userRewardInfos[account].ethAmount);
    }

    /**
     * @dev 获取待领取的 KK Token 收益
     * @param account 质押账户
     * @return 待领取的 KK Token 收益
     */
    function earned(address account) external view returns (uint256) {
        return uint256(userRewardInfos[account].rewardAmount);
    }
}
