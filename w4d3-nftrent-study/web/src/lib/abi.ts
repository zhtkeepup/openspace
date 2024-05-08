// TODO: 配置合约ABI
export const marketABI = [
  {
    type: "constructor",
    inputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "borrow",
    inputs: [
      {
        name: "order",
        type: "tuple",
        internalType: "struct RenftMarket.RentoutOrder",
        components: [
          {
            name: "maker",
            type: "address",
            internalType: "address",
          },
          {
            name: "nft_ca",
            type: "address",
            internalType: "address",
          },
          {
            name: "token_id",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "daily_rent",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "max_rental_duration",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "min_collateral",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "list_endtime",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
      {
        name: "makerSignature",
        type: "bytes",
        internalType: "bytes",
      },
    ],
    outputs: [],
    stateMutability: "payable",
  },
  {
    type: "function",
    name: "borrowedOrders",
    inputs: [
      {
        name: "",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
    outputs: [
      {
        name: "taker",
        type: "address",
        internalType: "address",
      },
      {
        name: "collateral",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "start_time",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "rentinfo",
        type: "tuple",
        internalType: "struct RenftMarket.RentoutOrder",
        components: [
          {
            name: "maker",
            type: "address",
            internalType: "address",
          },
          {
            name: "nft_ca",
            type: "address",
            internalType: "address",
          },
          {
            name: "token_id",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "daily_rent",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "max_rental_duration",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "min_collateral",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "list_endtime",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "cancelOrder",
    inputs: [
      {
        name: "order",
        type: "tuple",
        internalType: "struct RenftMarket.RentoutOrder",
        components: [
          {
            name: "maker",
            type: "address",
            internalType: "address",
          },
          {
            name: "nft_ca",
            type: "address",
            internalType: "address",
          },
          {
            name: "token_id",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "daily_rent",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "max_rental_duration",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "min_collateral",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "list_endtime",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
      {
        name: "makerSignatre",
        type: "bytes",
        internalType: "bytes",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "canceledOrders",
    inputs: [
      {
        name: "",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
    outputs: [
      {
        name: "",
        type: "bool",
        internalType: "bool",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "eip712Domain",
    inputs: [],
    outputs: [
      {
        name: "fields",
        type: "bytes1",
        internalType: "bytes1",
      },
      {
        name: "name",
        type: "string",
        internalType: "string",
      },
      {
        name: "version",
        type: "string",
        internalType: "string",
      },
      {
        name: "chainId",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "verifyingContract",
        type: "address",
        internalType: "address",
      },
      {
        name: "salt",
        type: "bytes32",
        internalType: "bytes32",
      },
      {
        name: "extensions",
        type: "uint256[]",
        internalType: "uint256[]",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "orderHash",
    inputs: [
      {
        name: "order",
        type: "tuple",
        internalType: "struct RenftMarket.RentoutOrder",
        components: [
          {
            name: "maker",
            type: "address",
            internalType: "address",
          },
          {
            name: "nft_ca",
            type: "address",
            internalType: "address",
          },
          {
            name: "token_id",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "daily_rent",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "max_rental_duration",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "min_collateral",
            type: "uint256",
            internalType: "uint256",
          },
          {
            name: "list_endtime",
            type: "uint256",
            internalType: "uint256",
          },
        ],
      },
    ],
    outputs: [
      {
        name: "",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "event",
    name: "BorrowNFT",
    inputs: [
      {
        name: "taker",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "maker",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "orderHash",
        type: "bytes32",
        indexed: false,
        internalType: "bytes32",
      },
      {
        name: "collateral",
        type: "uint256",
        indexed: false,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "EIP712DomainChanged",
    inputs: [],
    anonymous: false,
  },
  {
    type: "event",
    name: "OrderCanceled",
    inputs: [
      {
        name: "maker",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "orderHash",
        type: "bytes32",
        indexed: false,
        internalType: "bytes32",
      },
    ],
    anonymous: false,
  },
  {
    type: "error",
    name: "CheckError",
    inputs: [
      {
        name: "",
        type: "string",
        internalType: "string",
      },
    ],
  },
  {
    type: "error",
    name: "ECDSAInvalidSignature",
    inputs: [],
  },
  {
    type: "error",
    name: "ECDSAInvalidSignatureLength",
    inputs: [
      {
        name: "length",
        type: "uint256",
        internalType: "uint256",
      },
    ],
  },
  {
    type: "error",
    name: "ECDSAInvalidSignatureS",
    inputs: [
      {
        name: "s",
        type: "bytes32",
        internalType: "bytes32",
      },
    ],
  },
  {
    type: "error",
    name: "InvalidShortString",
    inputs: [],
  },
  {
    type: "error",
    name: "StringTooLong",
    inputs: [
      {
        name: "str",
        type: "string",
        internalType: "string",
      },
    ],
  },
];

// ERC721 ABI
export const ERC721ABI = [
  {
    type: "function",
    name: "approve",
    inputs: [
      {
        name: "to",
        type: "address",
        internalType: "address",
      },
      {
        name: "tokenId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "balanceOf",
    inputs: [
      {
        name: "owner",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "balance",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "getApproved",
    inputs: [
      {
        name: "tokenId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "operator",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "isApprovedForAll",
    inputs: [
      {
        name: "owner",
        type: "address",
        internalType: "address",
      },
      {
        name: "operator",
        type: "address",
        internalType: "address",
      },
    ],
    outputs: [
      {
        name: "",
        type: "bool",
        internalType: "bool",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "ownerOf",
    inputs: [
      {
        name: "tokenId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [
      {
        name: "owner",
        type: "address",
        internalType: "address",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "safeTransferFrom",
    inputs: [
      {
        name: "from",
        type: "address",
        internalType: "address",
      },
      {
        name: "to",
        type: "address",
        internalType: "address",
      },
      {
        name: "tokenId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "safeTransferFrom",
    inputs: [
      {
        name: "from",
        type: "address",
        internalType: "address",
      },
      {
        name: "to",
        type: "address",
        internalType: "address",
      },
      {
        name: "tokenId",
        type: "uint256",
        internalType: "uint256",
      },
      {
        name: "data",
        type: "bytes",
        internalType: "bytes",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "setApprovalForAll",
    inputs: [
      {
        name: "operator",
        type: "address",
        internalType: "address",
      },
      {
        name: "approved",
        type: "bool",
        internalType: "bool",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "function",
    name: "supportsInterface",
    inputs: [
      {
        name: "interfaceId",
        type: "bytes4",
        internalType: "bytes4",
      },
    ],
    outputs: [
      {
        name: "",
        type: "bool",
        internalType: "bool",
      },
    ],
    stateMutability: "view",
  },
  {
    type: "function",
    name: "transferFrom",
    inputs: [
      {
        name: "from",
        type: "address",
        internalType: "address",
      },
      {
        name: "to",
        type: "address",
        internalType: "address",
      },
      {
        name: "tokenId",
        type: "uint256",
        internalType: "uint256",
      },
    ],
    outputs: [],
    stateMutability: "nonpayable",
  },
  {
    type: "event",
    name: "Approval",
    inputs: [
      {
        name: "owner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "approved",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "tokenId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "ApprovalForAll",
    inputs: [
      {
        name: "owner",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "operator",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "approved",
        type: "bool",
        indexed: false,
        internalType: "bool",
      },
    ],
    anonymous: false,
  },
  {
    type: "event",
    name: "Transfer",
    inputs: [
      {
        name: "from",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "to",
        type: "address",
        indexed: true,
        internalType: "address",
      },
      {
        name: "tokenId",
        type: "uint256",
        indexed: true,
        internalType: "uint256",
      },
    ],
    anonymous: false,
  },
];
