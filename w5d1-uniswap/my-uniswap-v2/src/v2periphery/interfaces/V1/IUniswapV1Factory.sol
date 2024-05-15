// pragma solidity >=0.5.0;
pragma solidity =0.8.20;

interface IUniswapV1Factory {
    function getExchange(address) external view returns (address);
}
