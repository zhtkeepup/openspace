// pragma solidity >=0.5.0;
pragma solidity =0.8.20;

interface IUniswapV2Migrator {
    function migrate(
        address token,
        uint amountTokenMin,
        uint amountETHMin,
        address to,
        uint deadline
    ) external;
}
