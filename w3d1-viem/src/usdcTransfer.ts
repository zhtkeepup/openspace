
import { publicClient } from './client'
import { parseAbiItem } from 'viem'
 


// async function getBlockNumber() {
//     // const blockNumber = await publicClient.getBlockNumber();
//     const filter = await publicClient.createEventFilter()
//     console.log(filter);
// }

// getBlockNumber()


/*
使用 Viem 编写 ts 脚本查询Ethereum链上最近100个区块链内的 USDC Transfer记录，要求如下：

按格式输出转账记录：
从 0x099bc3af8a85015d1A39d80c42d10c023F5162F0 转账给 0xA4D65Fd5017bB20904603f0a174BBBD04F81757c 99.12345 USDC ,交易ID：0xd973feef63834ed1e92dd57a1590a4ceadf158f731e44aa84ab5060d17336281

*/
// usdc contract on ethereum: 

/**
 * 将给定的bigint整除1000000后保留小数位，以字符串形式返回
 * @param aBigint 
 * @returns 
 */
function bigintToStr6(aBigint: bigint) {
    const dd = aBigint/1000000n;
    const xx = aBigint % 1000000n;
    return ""+dd+"."+xx;
}

const usdcAddr = "0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48"

async function printUsdcTransfer100Block() {
    const blockNumber = await publicClient.getBlockNumber();
    console.log("最新区块高度 = "+blockNumber);
    const begin = blockNumber - BigInt(100);
    const end = blockNumber
    console.log("查询区块范围: " + begin + " - " + end +"(含)");
    
    const filter = await publicClient.createEventFilter({
        address: usdcAddr,
        event: parseAbiItem('event Transfer(address indexed from, address indexed to, uint256 value)'), 
        fromBlock: begin,
        toBlock: end
    });

    const logs = await publicClient.getFilterLogs({filter});

    logs.forEach((log) => {
        console.log(`从 ${log.args.from} 转账给 ${log.args.to} ${bigintToStr6(log.args.value!)} USDC ,交易ID：${log.transactionHash}`);
    });
}


printUsdcTransfer100Block().catch((err) => {
    console.log(err);
});


/*
(事先安装ts-node:npm install -g typescript ts-node)
执行命令:
ts-node src/usdcTransfer.ts

*/