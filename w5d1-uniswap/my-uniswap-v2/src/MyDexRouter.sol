// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.20;

import {UniswapV2Router02} from "./v2periphery/UniswapV2Router02.sol";
import "./v2periphery/libraries/UniswapV2Library.sol";
/**
 编写 MyDex 合约，任何人都可以通过 sellETH 方法出售ETH兑换成 USDT，
 也可以通过 buyETH 将 USDT 兑换成 ETH。
*/
interface IDex {
    /**
     * @dev 卖出ETH，兑换成 buyToken
     *      msg.value 为出售的ETH数量
     * @param buyToken 兑换的目标代币地址
     * @param minBuyAmount 要求最低兑换到的 buyToken 数量
     */
    function sellETH(address buyToken, uint256 minBuyAmount) external payable;

    /**
     * @dev 买入ETH，用 sellToken 兑换
     * @param sellToken 出售的代币地址
     * @param sellAmount 出售的代币数量
     * @param minBuyAmount 要求最低兑换到的ETH数量
     */
    function buyETH(
        address sellToken,
        uint256 sellAmount,
        uint256 minBuyAmount
    ) external;
}

contract MyDexRouter is UniswapV2Router02 {
    address public immutable USDT;
    constructor(
        address _factory,
        address _WETH,
        address _USDT
    ) public UniswapV2Router02(_factory, _WETH) {
        // factory = _factory;
        // WETH = _WETH;
        USDT = _USDT;
    }

    function pairOfETHUSDT() external view returns (address) {
        return UniswapV2Library.pairFor(factory, WETH, USDT);
    }

    function myAddLiquidityETH(
        address token,
        uint amountTokenDesired
    ) external payable {
        (uint amountToken, uint amountETH, uint liquidity) = addLiquidityETH(
            token,
            amountTokenDesired,
            1,
            1,
            msg.sender,
            block.timestamp + 100
        );
    }

    // 直接是USDT吧，不用指定代币了
    // function sellETH(address buyToken, uint256 minBuyAmount) external payable {}
    function sellETHUSDT(uint256 outUsdtAmountMin) external payable {
        address[] memory path = new address[](2);
        path[0] = WETH;
        path[1] = USDT;
        uint[] memory amounts = swapExactETHForTokens(
            outUsdtAmountMin,
            path,
            msg.sender,
            block.timestamp + 100
        );
    }

    function buyETHUSDT(
        uint256 buyEthAmount, // 指定购买的ETH数量
        uint256 inUsdtAmountMax // 最大可支出的USDT数量
    ) external {
        address[] memory path = new address[](2);
        path[0] = USDT;
        path[1] = WETH;
        uint[] memory amounts = swapTokensForExactETH(
            buyEthAmount,
            inUsdtAmountMax,
            path,
            msg.sender,
            block.timestamp + 100
        );
    }
}
