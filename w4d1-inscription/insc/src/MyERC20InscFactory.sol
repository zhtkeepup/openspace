// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "./BaseERC20VarSlot.sol";

import "./MyERC20InscMin.sol";
import "./MyERC20InscImpl.sol";

/**
要求：

包含测试用例：
费用按比例正确分配到发行者账号及项目方账号。
每次发行的数量正确，且不会超过 totalSupply.
请包含运行测试的截图或日志

 */

/*
 最小代理的原意，应该是使用"copy"的方式直接根据已经部署好的合约对象复制一个新的合约。通过opcode实现。
 opcode目前还不会。换种方式实现吧，以达到节省gas的目的.
 */
contract MyERC20InscFactory is BaseERC20VarSlot {
    mapping(string => address) public inscContracts;

    // key 是合约地址， value是调用deployInscription的用户
    mapping(address => address) public inscContracts2;

    uint256 constant fee = 2; // mint手续费, 定义为2 wei,

    constructor() {
        implementation = address(new MyERC20InscImpl(address(this)));
    }

    /**
    ⽤户调⽤该⽅法创建 ERC20 Token合约，symbol 表示新创建代币的代号（ ERC20 代币名字可以使用固定的），totalSupply 表示总发行量， perMint 表示单次的创建量， price 表示每个代币铸造时需要的费用（wei 计价）。每次铸造费用在扣除手续费后（手续费请自定义）由调用该方法的用户收取。
     */
    function deployInscription(
        string calldata symbol,
        uint totalSupply,
        uint perMint,
        uint price // price 表示每个代币铸造时需要的费用（wei 计价）
    ) public returns (address) {
        require(inscContracts[symbol] == address(0), "symbol exists!");
        require(price * perMint >= fee, "price too small");

        MyERC20InscMin insc = new MyERC20InscMin(address(this), implementation);

        // call
        (bool success, bytes memory data) = address(insc).call(
            abi.encodeWithSignature(
                "initDeploy(string,uint256,uint256,uint256)",
                symbol,
                totalSupply,
                perMint,
                price
            )
        );
        if (success) {
            inscContracts[symbol] = address(insc);
            inscContracts2[address(insc)] = msg.sender;
            return address(insc);
        } else {
            revert("init error!");
        }
    }

    /**
    每次调用发行创建时确定的 perMint 数量的 token，并收取相应的费用。
     */
    function mintInscription(address tokenAddr) public payable {
        require(
            inscContracts2[tokenAddr] != address(0),
            "Inscription contract is not exists!"
        );

        // 这里先控制大于fee。在mintInscription内部再控制剩余金额要大于铸造费用
        require(msg.value >= fee, "cost too small!");

        uint256 mintCost0 = msg.value - fee; // 用户支付的eth数量里，其中的手续费给当前工厂，其余的费用给第一个调用deploy的人
        (payable(inscContracts2[tokenAddr])).transfer(mintCost0);

        // 这个地址实际是通过 MyERC20InscMin类型 部署的，这里通过 Impl 类型去调用，内部走 delegatecall
        MyERC20InscImpl insc = MyERC20InscImpl(tokenAddr);
        insc.mintInscription(msg.sender, msg.value); // 传入msg.value 用于判断是否足额
    }
}
