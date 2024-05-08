import { createPublicClient, http } from 'viem'
import { formatEther } from 'viem'
import { mainnet } from 'viem/chains'

import { createWalletClient, parseAbi, custom } from 'viem'

import { privateKeyToAccount } from 'viem/accounts'



export const publicClient = createPublicClient({
    chain: mainnet,
    transport: http("https://eth-sepolia.g.alchemy.com/v2/jrvBMymLzPjSOTt6IoKelzCelQ4dRQGs")
})



