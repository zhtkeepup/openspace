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

import { NFTCreated as S2NFTDatasource } from "../generated/templates"

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
  S2NFTDatasource.create(event.params.nftCA);
}

