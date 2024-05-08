import { createPublicClient, http } from 'viem'
import { formatEther } from 'viem'
import { mainnet } from 'viem/chains'

import { createWalletClient, parseAbi, custom } from 'viem'

import { privateKeyToAccount } from 'viem/accounts'

import 'viem/window'

export const publicClient = createPublicClient({
    chain: mainnet,
    transport: http("https://eth-sepolia.g.alchemy.com/v2/jrvBMymLzPjSOTt6IoKelzCelQ4dRQGs")
})



async function main1() {
    const blockNumber = await publicClient.getBlockNumber()
    console.log("blockNumber:", blockNumber);

    const balance = await publicClient.getBalance({
        address: '0xA0Cf798816D4b9b9866b5330EEa46a18382f251e',
        // blockNumber: 69420n
    })
    const balanceAsEther = formatEther(balance)
    console.log("balance:", balance, balanceAsEther);
}

async function main2() {
    const transactionCount = await publicClient.getTransactionCount({
        address: '0xA0Cf798816D4b9b9866b5330EEa46a18382f251e',
        // blockNumber: 69420n,
        blockTag: 'safe' // 'latest' | 'earliest' | 'pending' | 'safe' | 'finalized' 类型： 'latest' | 'earliest' | 'pending' | 'safe' | 'finalized'
    })
    console.log("transactionCount:", transactionCount);
}

async function main3() {
    const block = await publicClient.getBlock()
    console.log("block:", block);
}

async function main4() {
    const unwatch = publicClient.watchBlockNumber(
        { onBlockNumber: blockNumber => console.log("unwatch:", blockNumber) }
    )
}




async function main5xxx() {
    const walletClient = createWalletClient({
        chain: mainnet,
        transport: custom(window.ethereum!),
    })

    // JSON-RPC Account
    const [account] = await walletClient.getAddresses()

    // Local Account
    // const account = privateKeyToAccount(...)

    const hash = await walletClient.sendTransaction({
        account,
        to: '0xd2eb0398e8507bc1e324070d1ef329f920aa0d6e',
        value
            : 1n
    })


    // parseAbi;
}


async function main5() {
    // Retrieve Account from an EIP-1193 Provider.
    const [account] = await window.ethereum.request({
        method: 'eth_requestAccounts'
    })

    // rpc account
    const walletClientRpc = createWalletClient({
        account,
        transport: custom(window.ethereum!)
    })

    const hash = await walletClientRpc.sendTransaction({
        to: 'd2eb0398e8507bc1e324070d1ef329f920aa0d6e',
        value: 1n
    })
}


main5()
