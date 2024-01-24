// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract AddressStorage is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(address => bool) private users;

    event UserAdded(address indexed user);

    function initialize() initializer public {
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function addUser() external {
        require(!users[msg.sender], "User already exists");
        users[msg.sender] = true;
        emit UserAdded(msg.sender);
    }
}