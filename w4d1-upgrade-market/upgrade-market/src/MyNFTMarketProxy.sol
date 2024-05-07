// SPDX-License-Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (proxy/transparent/TransparentUpgradeableProxy.sol)

pragma solidity ^0.8.20;

import {ERC1967Utils} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Utils.sol";
import {ERC1967Proxy} from "../lib/openzeppelin-contracts/contracts/proxy/ERC1967/ERC1967Proxy.sol";
import {IERC1967} from "../lib/openzeppelin-contracts/contracts/interfaces/IERC1967.sol";

contract MyNFTMarketProxy is ERC1967Proxy {
    error ProxyDeniedAdminAccess();

    constructor(
        address _logic,
        bytes memory _data
    ) payable ERC1967Proxy(_logic, _data) {
        // Set the storage value and emit an event for ERC-1967 compatibility
        ERC1967Utils.changeAdmin(msg.sender);
    }

    /**
     * @dev Returns the admin of this proxy.
     */
    function getAdmin() public returns (address) {
        return ERC1967Utils.getAdmin();
    }

    function changeAdmin(address newAdmin) public {
        if (ERC1967Utils.getAdmin() != msg.sender) {
            revert ProxyDeniedAdminAccess();
        }
        ERC1967Utils.changeAdmin(newAdmin);
    }

    function getImplementation() public view returns (address) {
        return _implementation();
    }

    /**
     *
     * Requirements:
     *
     * - If `data` is empty, `msg.value` must be zero.
     */
    function upgradeMarketImpl(
        address newImplementation,
        string memory checkCode
    ) public {
        if (
            ERC1967Utils.getAdmin() == msg.sender &&
            keccak256(bytes("upgradeMarketImpl")) == keccak256(bytes(checkCode))
        ) {
            // (address newImplementation, bytes memory data) = abi.decode(msg.data[4:],(address, bytes));
            bytes memory data;
            ERC1967Utils.upgradeToAndCall(newImplementation, data);
        } else {
            super._fallback();
        }
    }
}
