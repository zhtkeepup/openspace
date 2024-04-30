import {
  NFTCreated as NFTCreatedEvent,
  NFTRegesitered as NFTRegesiteredEvent,
  OwnershipTransferred as OwnershipTransferredEvent,
  Transfer as TransferEvent
} from "../generated/NFTFactory0x9e72/NFTFactory0x9e72"
import {
  NFTCreated,
  NFTRegesitered,
  OwnershipTransferred,
  TokenInfo,
  Transfer
} from "../generated/schema"

import { S2NFT } from "../generated/templates/S2NFT/S2NFT"

export function handleNFTCreated(event: NFTCreatedEvent): void {
  let entity = new NFTCreated(
    event.params.nftCA
    // event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleNFTRegesitered(event: NFTRegesiteredEvent): void {
  let entity = new NFTRegesitered(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.nftCA = event.params.nftCA

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

export function handleOwnershipTransferred(
  event: OwnershipTransferredEvent
): void {
  let entity = new OwnershipTransferred(
    event.transaction.hash.concatI32(event.logIndex.toI32())
  )
  entity.previousOwner = event.params.previousOwner
  entity.newOwner = event.params.newOwner

  entity.blockNumber = event.block.number
  entity.blockTimestamp = event.block.timestamp
  entity.transactionHash = event.transaction.hash

  entity.save()
}

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
    tokenInfo.save();
  }

}

