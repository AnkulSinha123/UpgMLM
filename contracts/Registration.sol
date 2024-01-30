// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Registration is Initializable, OwnableUpgradeable {
    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered; // New field to track registration status
        string uniqueId; // New field to store unique ID
    }

    mapping(address => UserInfo) public allUsers;
    mapping(string => address) public userAddressByUniqueId; // Mapping to store user addresses by unique ID

    event UserRegistered(address indexed user, address indexed referrer);

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function getUniqueId(address user) public pure returns (string memory) {
        return toString(uint160(user) % 1e10);
    }

    function toString(uint256 value) internal pure returns (string memory) {
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

        for (uint256 i = 0; i < digits; i++) {
            buffer[i] = bytes1(
                uint8(48 + ((value / 10**(digits - 1 - i)) % 10))
            );
        }

        return string(buffer);
    }

    function register(string memory referrerUniqueId) external {
        string memory userUniqueId = getUniqueId(msg.sender);
        address referrer = findReferrerByUniqueId(referrerUniqueId);

        UserInfo storage user = allUsers[msg.sender];
        UserInfo storage referrerInfo = allUsers[referrer];

        require(
            referrerInfo.isRegistered || referrer == owner(),
            "Not registered"
        );
        require(!user.isRegistered, "Already registered");

        user.uniqueId = userUniqueId;
        user.referrer = referrer;
        user.isRegistered = true;
        referrerInfo.referrals.push(msg.sender);

        userAddressByUniqueId[userUniqueId] = msg.sender;

        emit UserRegistered(msg.sender, referrer);
    }

    function registerByOwner() external onlyOwner {
        address ownerAddress = owner();
        require(!allUsers[ownerAddress].isRegistered, "Already registered");

        string memory ownerUniqueId = getUniqueId(ownerAddress);

        UserInfo storage ownerInfo = allUsers[ownerAddress];
        ownerInfo.uniqueId = ownerUniqueId;
        ownerInfo.referrer = ownerAddress;
        ownerInfo.isRegistered = true;
        ownerInfo.referrals.push(ownerAddress);

        // Update the mapping with the user's address
        userAddressByUniqueId[ownerUniqueId] = ownerAddress;

        emit UserRegistered(ownerAddress, address(0));
    }

    function findReferrerByUniqueId(string memory referrerUniqueId)
        internal
        view
        returns (address)
    {
        address referrerAddress = userAddressByUniqueId[referrerUniqueId];
        require(referrerAddress != address(0), "Referrer not found");
        return referrerAddress;
    }

    function getReferrals(address user)
        external
        view
        returns (address[] memory)
    {
        return allUsers[user].referrals;
    }
}
