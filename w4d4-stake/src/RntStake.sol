// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";

import {EsRnt} from "./EsRnt.sol";

import {RntERC20} from "./RntERC20.sol";

contract RntStake {
    RntERC20 public immutable rnt;

    EsRnt public immutable esRnt;

    constructor(address _rntCa, address _esRntCa) {
        rnt = RntERC20(_rntCa);
        esRnt = EsRnt(_esRntCa);
    }

    struct StkInfo {
        uint256 amount; // 用户质押数量
        uint256 lastUpdate; // 上次计算时间
        uint256 esRntReward; // 已计算可得的esRnt的奖励数量
    }

    // 外部用户查询时，按照该结构返回
    struct StkInfoForView {
        uint256 amount; // 用户质押数量
        uint256 esRntReward; // 当前可得的esRnt的奖励数量
    }

    // 质押数据
    mapping(address => StkInfo) public stakes;

    struct LockInfo {
        uint256 lockedAmount; // 累计被锁定的数量
        uint256 lastUpdate; // 上次计算时间
        uint256 unlockAmount; // 计算后，累计可解锁的数量
        uint256 burnAmount; // 计算后，（若提前兑换）将被燃烧的数量
    }

    // 外部用户查询时，按照该结构返回
    struct LockInfoForView {
        uint256 lockedAmount; // 累计被锁定的数量
        uint256 unlockAmount; // 累计可解锁的数量
        uint256 burnAmount; // （若提前兑换）将被燃烧的数量
    }

    // esRnt锁定信息
    mapping(address => LockInfo) public locks;

    event Stake(address, uint256);
    event UnStake(address, uint256);
    event Claim(address, uint256);
    event Exchange(address, uint256, uint256, uint256);

    // 质押
    function stake(uint256 _amount) external before {
        if (stakes[msg.sender].lastUpdate == 0) {
            stakes[msg.sender] = StkInfo(_amount, block.timestamp, 0);
        } else {
            StkInfo storage s = stakes[msg.sender];
            s.amount += _amount;
            // stakes[msg.sender] = s;
        }

        rnt.transferFrom(msg.sender, address(this), _amount);

        emit Stake(msg.sender, _amount);
    }

    function queryStakeInfo(
        address user
    ) external view returns (StkInfoForView memory info) {
        StkInfo storage s = stakes[user];
        info = StkInfoForView(
            s.amount,
            s.esRntReward + algReward(s.amount, s.lastUpdate)
        );
    }

    // 解除质押().
    function unstake(uint256 _amount) external before {
        require(_amount <= (stakes[msg.sender]).amount, "Insufficient1!");

        StkInfo storage s = stakes[msg.sender];
        s.amount -= _amount;

        rnt.transferFrom(address(this), msg.sender, _amount);

        emit UnStake(msg.sender, _amount);
    }

    // 领取奖励
    function claim() external before {
        require((stakes[msg.sender]).esRntReward > 0, "Insufficient2!");

        StkInfo storage s = stakes[msg.sender];

        esRnt.mint(msg.sender, s.esRntReward);

        emit Claim(msg.sender, s.esRntReward);

        updateLock(s.esRntReward); // 更新 esRnt 的锁仓信息

        s.esRntReward = 0;
    }

    // 每次操作之前先计算并记录已有的奖励
    modifier before() {
        StkInfo storage s = stakes[msg.sender];
        if (s.amount > 0) {
            s.esRntReward += algReward(s.amount, s.lastUpdate);
            s.lastUpdate = block.timestamp;
        }

        _;
    }

    // 计算奖励, //每质押1个RNT每天可奖励 1 esRNT
    function algReward(
        uint256 amount,
        uint256 lastUpdate
    ) internal view returns (uint256) {
        return (amount * (block.timestamp - lastUpdate)) / (24 * 3600);
    }

    // 计算解锁量。esRNT 是锁仓性的 RNT， 1 esRNT 在 30 天后可兑换 1 RNT，随时间线性释放
    function algUnlock(
        uint256 amount,
        uint256 lastUpdate
    ) internal view returns (uint256) {
        uint256 uu = (amount * (block.timestamp - lastUpdate)) / 24 / 3600 / 30;
        if (uu > amount) {
            return amount; // 解锁的量不应该超过原本就有的量
        } else {
            return uu;
        }
    }

    // 领取奖励时(或者兑换时)调用本方法更新锁仓信息
    function updateLock(uint256 _lockedAmount) internal {
        if (locks[msg.sender].lastUpdate == 0) {
            locks[msg.sender] = LockInfo(
                _lockedAmount, // 累计被锁定的数量
                block.timestamp, // 上次计算时间
                0, // 计算后，累计可解锁的数量
                _lockedAmount // 计算后，（若提前兑换）将被燃烧的数量
            );
        } else {
            LockInfo storage lk = locks[msg.sender];

            uint256 newUnlock = algUnlock(
                lk.lockedAmount - lk.unlockAmount,
                lk.lastUpdate
            );

            lk.lockedAmount += _lockedAmount;
            lk.lastUpdate = block.timestamp;
            lk.unlockAmount += newUnlock;
            lk.burnAmount -= newUnlock;
        }
    }

    // 查询锁仓信息
    function queryLockInfo(
        address user
    ) external view returns (LockInfoForView memory info) {
        LockInfo storage lk = locks[user]; // msg.sender

        uint256 newUnlock = algUnlock(
            lk.lockedAmount - lk.unlockAmount,
            lk.lastUpdate
        );

        info = LockInfoForView(
            lk.lockedAmount, // 已持有信息
            lk.unlockAmount + newUnlock, // 已解锁量
            lk.burnAmount - newUnlock // 提前解锁被销毁的量.
        );
    }

    // 兑换。
    // 若未全部解锁，则当 unlockBurn 为true时，未解锁部分将会销毁。
    // 否则未全部解锁时不能兑换。
    // (rsRNT本身已经做了限制：不能转账)
    function exchangeEsRnt(bool unlockBurn) external {
        updateLock(0);
        LockInfo storage lk = locks[msg.sender];
        if (!unlockBurn) {
            require(lk.burnAmount == 0, "still unlocked amounts!");
        }

        rnt.mint(msg.sender, lk.unlockAmount);

        emit Exchange(
            msg.sender,
            lk.lockedAmount,
            lk.unlockAmount,
            lk.burnAmount
        );

        lk.lockedAmount = 0; // 有存在未解锁的，则也直接被“销毁”，无法再兑换.
        lk.unlockAmount = 0;
        lk.burnAmount = 0;
    }
}
