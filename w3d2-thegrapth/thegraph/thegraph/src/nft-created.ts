import {
    NFTCreated as NFTCreatedEvent,
    NFTRegesitered as NFTRegesiteredEvent,
    OwnershipTransferred as OwnershipTransferredEvent,
    Transfer as TransferEvent
  } from "../generated/NFTFactory0x9e72/NFTFactory0x9e72"
  import {
    NFTCreated,
    TokenInfo,
    Transfer
  } from "../generated/schema"
  
  import {BigInt, Bytes} from "@graphprotocol/graph-ts"
  
  import { S2NFT } from "../generated/templates/NFTCreated/S2NFT"
  
  
  export function handleTransfer(
    event: TransferEvent
  ): void {
    let entity = new Transfer(
      event.transaction.hash.concatI32(event.logIndex.toI32())
    )
    entity.from = event.params.from
    entity.to = event.params.to
    entity.tokenId = event.params.tokenId
    entity.save()
  
    let entityNFT = NFTCreated.load(event.address);
  
    if(entityNFT != null) {
      let contract = S2NFT.bind(event.address)
      let tokenInfo = new TokenInfo(entityNFT.nftCA.toHexString().concat("#").concat(entity.tokenId.toString()));
      tokenInfo.ca = entityNFT.nftCA;
      tokenInfo.tokenId = entity.tokenId;
      tokenInfo.tokenURL = contract.tokenURI(tokenInfo.tokenId);
      tokenInfo.name = contract.name();
      tokenInfo.owner = entity.to;
  
      // event.block.number = BigInt.zero();
      tokenInfo.blockTimestamp = BigInt.zero();
      tokenInfo.transactionHash = Bytes.fromI32(0);
      if(event.block.number === null) {
        tokenInfo.blockNumber = BigInt.zero();
      } else {
        tokenInfo.blockNumber = event.block.number;
      }
      tokenInfo.blockTimestamp = event.block.timestamp === null ? BigInt.zero() : event.block.timestamp;
      tokenInfo.transactionHash = event.transaction.hash === null ? Bytes.fromI32(0) : event.transaction.hash;
  
      tokenInfo.save();
    }
  
  }
  
  