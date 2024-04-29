
import { createPublicClient, http } from 'viem'
import { mainnet } from 'viem/chains'




export const publicClient = createPublicClient({
  chain: mainnet,
  transport: http("https://eth-mainnet.g.alchemy.com/v2/iIXO9lqosmQABnPyVYfZmrRm1bT8E3sb"),
})


/*
const client = createPublicClient({ 
  chain: mainnet, 
  transport: http("https://eth-mainnet.g.alchemy.com/v2/iIXO9lqosmQABnPyVYfZmrRm1bT8E3sb"), 
}) 


async function getBlockNumber() {
    const blockNumber = await client.getBlockNumber();
    console.log(blockNumber);
}

getBlockNumber();

*/

