// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Registration is Initializable, OwnableUpgradeable {

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered; // New field to track registration status
        string uniqueId;   // New field to store unique ID
    }

    mapping(address => UserInfo) public allUsers;
    mapping(string => address) public userAddressByUniqueId; // Mapping to store user addresses by unique ID

    event UserRegistered(address indexed user, address indexed referrer);

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function getUniqueId(address user) public pure returns (string memory) {
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

    function register(string memory referrerUniqueId) external {
        // Use the provided referrerUniqueId as the referrer
        string memory userUniqueId = getUniqueId(msg.sender);
        address referrer = findReferrerByUniqueId(referrerUniqueId);

        require(allUsers[referrer].isRegistered || referrer == owner(), "Not registered");
        require(!allUsers[msg.sender].isRegistered, "Already registered");

        // Set the unique ID to the user's unique ID
        allUsers[msg.sender].uniqueId = userUniqueId;
        allUsers[msg.sender].referrer = referrer;
        allUsers[msg.sender].isRegistered = true;
        allUsers[referrer].referrals.push(msg.sender);

        // Update the mapping with the user's address
        userAddressByUniqueId[userUniqueId] = msg.sender;

        emit UserRegistered(msg.sender, referrer);
    }

    function registerByOwner() external onlyOwner {
        string memory ownerUniqueId = getUniqueId(msg.sender);
        require(!allUsers[msg.sender].isRegistered, "Already registered");

        allUsers[msg.sender].uniqueId = ownerUniqueId;
        allUsers[msg.sender].referrer = owner();
        allUsers[msg.sender].isRegistered = true;
        allUsers[owner()].referrals.push(msg.sender);

        // Update the mapping with the user's address
        userAddressByUniqueId[ownerUniqueId] = msg.sender;

        emit UserRegistered(msg.sender, address(0));
    }


    function findReferrerByUniqueId(string memory referrerUniqueId) internal view returns (address) {
        // Retrieve the address associated with the unique ID from the mapping
        address referrerAddress = userAddressByUniqueId[referrerUniqueId];
        require(referrerAddress != address(0), "Referrer not found for the provided unique ID");
        return referrerAddress;
    }

    function getReferrals(address user) external view returns (address[] memory) {
        return allUsers[user].referrals;
    }
}
