### 20240419 题面

咱们的课程已经进行一个星期了，今天下午 4:00 我们将开展第一次一周总结，请各组长准备：
1、本周各组员的学习和成长状态，以及是否每个人都达了到自己的学习目标
2、本周小组的项目进展
3、本周组员们获取到的经验总结分享
4、本周存在的问题，以及下周准备怎么调整
5、是否有需要跟大家讨论的问题

### 20240119 答案

#### -- 项目进展：

    在丁总的指导下，经过多次深度沟通与交流，本周确定了小组计划实现的产品的初步形态。
    我们小组计划实现一个“web3世界的企业级账户及账务管理平台”，在两个月的学习期内计划首先完多账户管理及资产查询。
    同时小组取名为 deaccount 。

#### -- 经验总结分享：

##### ---- 初学区块链智能合约时遇到的困惑点及个人理解：

    1. 什么是合约的部署？
        以普通非区块链程序员的视角来理解，我想可以是这样：
        首先可以认为EVM是一个永不重启的虚拟机（就假设它是一个永不重启的程序），而EVM里的合约可以当成是这个虚拟机里的内存对象。部署合约，可以理解成外部世界向EVM发送指令，EVM根据指令创建一个内存对象，指令内容就是我们开发者编写的合约代码，创建生成的每个内存对象在EVM内有唯一的ID（即address），合约对象一旦创建，其内部的规则逻辑即不可篡改。
        所以，相同的程序代码，部署两次，就生成两个EVM内的合约对象，且两者相互独立没有任何关联，除非程序员在合约代码内实现一些有相互关联的逻辑。

    3. 什么是调用合约？
        调用合约就是类似于下面的语法：
         ContractBank('0x123abc').func123();
         如果在方法func123内部对合约对象里的变量进行修改，即发生了状态改变，则永久生效，不存在“重新部署或者重启恢复”的说法，若要名义上的恢复，应该重新调用某个已经实现的方法来修改变量（达到让它恢复的效果）。
         。
         转账是特殊的调用，使用固定的方法名transfer, 如 ContractBank('0x123abc').transfer(amount) ;

    2. 如何理解转账？
        EVM里（基于solidity代码部署的）的合约对象，虽然开发者在solidity代码里没有明确写明，但按照个人理解，每个合约对象可能都有一个隐含的transfer()方法，在合约代码里，其它合约对象或者EOA可以通过语法 payable('0x123abc').transfer(amount) 来调用这个方法，其目的是将调用者拥有的以太币转账给'0x123abc'这个地址对应的合约或者EOA。当transfer()方法完成后，调用者的余额自动减少，'0x123abc'的余额自动增加。
        两个账户的余额的增加与减少，不需要开发者处理，EVM内部自动会完成这个操作。同时，开发者可以通过 address('0x123abc').balance 来查询指定地址的账户余额。
        同时 ，若'0x123abc'是一个合约对象的地址，其transfer() 内部还有额外的处理规则：
        1. （首先具备两个账户间的金额转移功能， 因此开发者无需处理余额的变化）
        2. 若调用transfer()时附带额外数据，（这个额外数据可能包含函数名），则根据额外数据的指定，再去调用这个合约指定的方法。（被调用的指定的方法应该用payable修饰）
        3. 若调用transfer()时没有附带额外数据，则默认尝试调用 receive() 方法。 若该合约没有实现receive()方法，尝试调用fallback()方法，若也没有实现fallback()，则系统处理失败。 当触发receive或fallback时，这两个方法都应用payable修饰。

#### -- 存在的问题及改进点：

    1. 可能需要提前预习，直接听老师讲课然后直接做作业，难度有点高。