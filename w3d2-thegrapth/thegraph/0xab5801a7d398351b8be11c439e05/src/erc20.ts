import {
  Transfer as TransferEvent,
} from "../generated/Vitalik_0xab5801a7/erc20"
import {
  Transfer,
  Erc20Transaction,
  Erc20BalanceSnapshot
} from "../generated/schema"

import {
  TypedMap,
  Entity,
  Value,
  ValueKind,
  store,
  Bytes,
  BigInt,
  Int8,
  BigDecimal,
  ethereum,
  Address
} from "@graphprotocol/graph-ts";


import { erc20 as Erc20Contract } from "../generated/templates/erc20/erc20"

import { erc20 as Erc20Datasource } from "../generated/templates"

const myAddr = Bytes.fromHexString("0xab5801a7d398351b8be11c439e05c5b3259aec9b");

export function handleTransfer(event: TransferEvent): void {
  _handleTransfer(event, 1);
  _handleTransfer(event, 2);
}

function _handleTransfer(event: TransferEvent, type: number): void {
  let acctAddr = event.params.to;
  let oppoAddr = event.params.from;
  let value = event.params.value;
  if(type == 1) {
    // 记录from
    acctAddr = event.params.from;
    oppoAddr = event.params.to;
    value = value.times(BigInt.fromString("-1"));
  } else {
    // 记录to
  }

  let trans = new Erc20Transaction(
    event.transaction.hash.concatI32(event.logIndex.toI32()).concat(acctAddr)
  );

  trans.acctAddr = acctAddr;
  trans.oppoAddr = oppoAddr;
  trans.value = value;

  trans.tokenAddr = event.address;

  trans.blockNumber = event.block.number
  trans.blockTimestamp = event.block.timestamp
  trans.transactionHash = event.transaction.hash



/*

let tupleArray: Array<ethereum.Value> = [
  ethereum.Value.fromAddress(Address.fromString('0x0000000000000000000000000000000000000420')),
  ethereum.Value.fromUnsignedBigInt(BigInt.fromI32(62)),
]

let tuple = tupleArray as ethereum.Tuple

let encoded = ethereum.encode(ethereum.Value.fromTuple(tuple))!

let decoded = ethereum.decode('(address,uint256)', encoded)

*/
      // 临时:
      // let erc20Contract = Erc20Contract.bind(event.address);
      // if(erc20Contract.try_balanceOf(acctAddr).reverted) {
      //   trans.balanceTmp =  BigInt.fromString("0");
      // } else {
      //   trans.balanceTmp = erc20Contract.try_balanceOf(acctAddr).value; // balanceOf(acctAddr);
      // }



  trans.save()


  // 更新最新结果的快照(一个用户一个代币总是只有一条).....
  let snapId_latest = acctAddr.toHexString()+"_"+event.address.toHexString();
  let balanceSnap = Erc20BalanceSnapshot.load(snapId_latest);
  if(balanceSnap == null) {
    balanceSnap = new Erc20BalanceSnapshot(snapId_latest);
    let erc20Contract = Erc20Contract.bind(event.address);
    balanceSnap.acctAddr = acctAddr;
    balanceSnap.tokenAddr = event.address;
    if(erc20Contract.try_name().reverted) {
      balanceSnap.tokenName = balanceSnap.tokenAddr.toHexString();
    } else {
      balanceSnap.tokenName = erc20Contract.name();
    }
    if(erc20Contract.try_decimals().reverted) {
      balanceSnap.tokenDecimals = BigInt.fromString("1");
    } else {
      balanceSnap.tokenDecimals = erc20Contract.try_decimals().value;
    }
    if(erc20Contract.try_balanceOf(acctAddr).reverted) {
      balanceSnap.balance = BigInt.fromString("0");
    } else {
      balanceSnap.balance = erc20Contract.try_balanceOf(acctAddr).value; // balanceOf(acctAddr);
    }
    
    balanceSnap.snapshotBlockNumber = event.block.number;
    balanceSnap.snapshotBlockTimestamp = event.block.timestamp;
    balanceSnap.snapshotTransactionHash = event.transaction.hash;
    balanceSnap.tranCountSinceLast = BigInt.fromString("0");
    balanceSnap.save();
  } else {
    // 已经有的，基于先前数据累加
    balanceSnap.balance = balanceSnap.balance.plus(trans.value); //  = trans.value.div(contract.decimals().toBigDecimal());
    balanceSnap.snapshotBlockNumber = event.block.number;
    balanceSnap.snapshotBlockTimestamp = event.block.timestamp;
    balanceSnap.snapshotTransactionHash = event.transaction.hash;
    balanceSnap.tranCountSinceLast = balanceSnap.tranCountSinceLast.plus(BigInt.fromString("1"));

    balanceSnap.save();
  }


  // 更新周期性的历史快照(每个用户每个代币每个月一条)
  let snapId2 = acctAddr.toHexString()+"_"+event.address.toHexString()+"_"+event.block.number.toString().substring(0,7);// acctAddr+BlockNumber[:7]
  let balanceSnap2 = Erc20BalanceSnapshot.load(snapId2);
  if(balanceSnap2 == null) {
    balanceSnap2 = balanceSnap;
    balanceSnap2.id = snapId2;
    balanceSnap2.tranCountSinceLast = BigInt.fromString("0");
    balanceSnap2.save();
  } else {
    balanceSnap2.balance = balanceSnap2.balance.plus(trans.value); //  = trans.value.div(contract.decimals().toBigDecimal());
    balanceSnap2.snapshotBlockNumber = event.block.number;
    balanceSnap2.snapshotBlockTimestamp = event.block.timestamp;
    balanceSnap2.snapshotTransactionHash = event.transaction.hash;
    balanceSnap2.tranCountSinceLast = balanceSnap2.tranCountSinceLast.plus(BigInt.fromString("1"));
    balanceSnap2.save();
  }
}
