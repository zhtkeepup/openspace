const { MerkleTree } = require("merkletreejs");
// const SHA256 = require("crypto-js/sha256");
const keccak256 = require("keccak256");

const { encodeAbiParameters } = require("viem");

//
let whitelistAddresses = [
  "0x0000000000000000000000000000000000AaA111",
  "0xd5F5175D014F28c85F7D67A111C2c9335D7CD771",
  "0x0000000000000000000000000000000000CCC333",
];

const leaves = whitelistAddresses.map((addr) => keccak256(addr));
// const tree = new MerkleTree(leaves, keccak256, { sortPairs: true });
const tree = new MerkleTree(leaves, keccak256, { sort: true });
// const root_xxx = tree.getRoot().toString("hex");
const root = tree.getHexRoot();
// console.log("0x" + root);
// root: 0x5010d2b3d938779ec375de2449ded66e13e6f393b39d5c6475b33b6855a7072d
// console.log("tree:\n", tree.toString());

function printMerkleProof(address) {
  console.log("my keccak256:", keccak256(address));
  const leaf = keccak256(address);
  const proof = tree.getHexProof(leaf);
  console.log(proof);
  //   console.log("===================root:");
  //   console.log(root);

  //   console.log("===================");
  //   console.log(tree.toString());
  // console.log(JSON.stringify(proof));
  // console.log(address);
}

const args = process.argv.slice(2);

printMerkleProof(args[0]);

///////
///////
// verifying. ok
function verifyOk() {
  const leaf = keccak256("0x0000000000000000000000000000000000CCC333");
  const proof = tree.getProof(leaf);
  // console.log("a leaf's proof:\n", proof);
  console.log(tree.verify(proof, leaf, root)); // true
}

// bad
function verifyFail() {
  const badLeaves = ["0xa", "0xx", "0xc"].map((addr) => keccak256(addr));
  const badTree = new MerkleTree(badLeaves, keccak256, { sortPairs: true });
  const badLeaf = keccak256("0xx");
  const badProof = badTree.getProof(badLeaf);
  console.log(badTree.verify(badProof, badLeaf, root)); // false
}

// verifyOk();
// verifyFail();
