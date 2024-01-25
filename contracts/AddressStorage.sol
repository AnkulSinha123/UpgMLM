// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

contract AddressStorage is Initializable, UUPSUpgradeable, OwnableUpgradeable {
    mapping(address => bool) private users;
    mapping(address => string) private uniqueIds;

    event UserAdded(address indexed user, string uniqueId);

    function initialize() initializer public {
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address) internal override onlyOwner {}

    function addUser() external {
        require(!users[msg.sender], "User already exists");

        // Generate a unique ID using the last 10 digits of the wallet address
        string memory uniqueId = getLast10Digits(msg.sender);
        
        users[msg.sender] = true;
        uniqueIds[msg.sender] = uniqueId;

        emit UserAdded(msg.sender, uniqueId);
    }

    function getUniqueId(address user) external view returns (string memory) {
        return uniqueIds[user];
    }

    function getLast10Digits(address user) internal pure returns (string memory) {
    uint256 addressValue = uint256(uint160(user)); // Explicitly convert address to uint256

    // Extract the last 10 digits of the address and convert to a string
    return toString(addressValue % 1e10);
}


    function toString(uint256 value) internal pure returns (string memory) {
        // Convert the number to a string
        if (value == 0) {
            return "0";
        }

        uint256 temp = value;
        uint256 digits;
        
        while (temp != 0) {
            digits++;
            temp /= 10;
        }

        bytes memory buffer = new bytes(digits);

        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + (value % 10)));
            value /= 10;
        }

        return string(buffer);
    }
}
