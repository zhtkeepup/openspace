//SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

/*
编写一个 Bank 合约，实现功能：

可以通过 Metamask 等钱包直接给 Bank 合约地址存款
在 Bank 合约里记录每个地址的存款金额
编写 withdraw() 方法，仅管理员可以通过该方法提取资金。
用数组记录存款金额的前 3 名用户
请提交完成项目代码或 github 仓库地址。

*/

/*
在sepolia网络上测试时的信息：
交易哈希	0xa72d98e103fe3ca4c41a464753cd8413ebc179e9b311035df05f55391207d885
区块哈希	0xc885bae7136f85afcbab363feedf160c762acc8d60e0f6effa484d7b9abdc3a2
区块号	5722889
合约地址	0x93a1b12ffa712335532a9c781a20b971541158f6
*/

//
contract Bank {
    error NotSufficientFunds();

    address public admin;

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only Admin can call this function.");
        _;
    }

    // 记录下存款用户的余额，管理员提取资金后，用户余额不清零
    mapping(address => uint256) public userBalances;

    address[3] public top3_ = [address(0), address(0), address(0)];

    constructor() {
        admin = msg.sender;
    }

    // 设置新的管理员
    function setAdmin(address newAdmin) public onlyAdmin {
        admin = newAdmin;
    }

    // 需要在BigBank里继承，故使用virtual
    function updateTopThree() public payable virtual {
        userBalances[msg.sender] += msg.value;
        if (userBalances[msg.sender] <= userBalances[top3_[2]]) {
            return;
        } else if (userBalances[msg.sender] < userBalances[top3_[1]]) {
            // 抢占到第三名
            top3_[2] = msg.sender;
        } else if (userBalances[msg.sender] < userBalances[top3_[0]]) {
            // 抢占到第二名,如果原来第二名就是sender，就不用改了
            if (top3_[1] != msg.sender) {
                top3_[2] = top3_[1];
                top3_[1] = msg.sender;
            }
        } else {
            // 抢占到第一名,如果原来第三名就是sender，就不用改了
            if (top3_[0] != msg.sender) {
                top3_[2] = top3_[1];
                top3_[1] = top3_[0];
                top3_[0] = msg.sender;
            }
        }
    }

    // 接收金额后更新top three
    receive() external payable {
        updateTopThree();
    }

    /*  1. 管理员提取指定资金.指定数量是0，则全部提取.;
        2. 在BigBank里需要被Ownable合约调用，并将金额转移给EOA（不转移到Ownable合约），
           所以需要指定金额接收人.
        3. 接收人传入0时，则接收人认为是msg.sender
    */
    function withdraw(
        uint256 amount,
        address recipient
    ) public payable onlyAdmin {
        uint256 _amt = amount == 0 ? address(this).balance : amount;
        if (_amt > address(this).balance) revert NotSufficientFunds();

        address _rec = recipient == address(0) ? msg.sender : recipient;
        payable(_rec).transfer(_amt);
    }
}
