// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

contract MyWallet {
    string public name;
    mapping(address => bool) private approved;
    address public owner;

    modifier auth() {
        require(msg.sender == owner, "Not authorized");
        _;
    }

    constructor(string memory _name) {
        name = _name;
        owner = msg.sender;
    }

    function transferOwernship(address _addr) public auth {
        require(_addr != address(0), "New owner is the zero address");
        require(owner != _addr, "New owner is the same as the old owner");
        owner = _addr;
    }

    function getOwner() public view returns (address aa) {
        assembly {
            aa := sload(0x2)
        }
    }

    function setOwner(address _addr) public {
        require(_addr != address(0), "xxNew owner is the zero address");
        require(owner != _addr, "xxNew owner is the same as the old owner");

        assembly {
            sstore(0x2, _addr)
        }
    }
}
