// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Registration is Initializable, OwnableUpgradeable {
    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string uniqueId;
        uint256 timestamp;
    }

    mapping(address => UserInfo) public allUsers;
    mapping(string => address) public userAddressByUniqueId;
    uint256 public totalUsers;

    event UserRegistered(
        address indexed user,
        address indexed referrer,
        uint256 timestamp
    );

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
    }

    function GetIdFromAddress(address user)
        public
        pure
        returns (string memory)
    {
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

    function registerUser(string memory referrerUniqueId) external {
        address referrer = findReferrerByUniqueId(referrerUniqueId);

        UserInfo storage user = allUsers[msg.sender];
        UserInfo storage referrerInfo = allUsers[referrer];

        require(
            referrerInfo.isRegistered || referrer == owner(),
            "Not registered"
        );
        require(!user.isRegistered, "Already registered");

        user.uniqueId = GetIdFromAddress(msg.sender);
        user.referrer = referrer;
        user.isRegistered = true;
        referrerInfo.referrals.push(msg.sender);
        user.timestamp = block.timestamp;

        userAddressByUniqueId[user.uniqueId] = msg.sender;
        totalUsers++;

        emit UserRegistered(msg.sender, referrer, block.timestamp);
    }

    function registerByOwner() external onlyOwner {
        UserInfo storage ownerInfo = allUsers[owner()];

        require(!ownerInfo.isRegistered, "Already registered");

        ownerInfo.uniqueId = GetIdFromAddress(owner());
        ownerInfo.referrer = owner();
        ownerInfo.isRegistered = true;
        ownerInfo.referrals.push(owner());
        ownerInfo.timestamp = block.timestamp;

        userAddressByUniqueId[ownerInfo.uniqueId] = owner();
        totalUsers++;

        emit UserRegistered(owner(), address(0), block.timestamp);
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

    function getDirectReferrals(string memory uniqueId)
        external
        view
        returns (string[] memory)
    {
        address userAddress = userAddressByUniqueId[uniqueId];
        require(userAddress != address(0), "User not found");

        address[] memory referrals = allUsers[userAddress].referrals;
        string[] memory referralUniqueIds = new string[](referrals.length);

        for (uint256 i = 0; i < referrals.length; i++) {
            referralUniqueIds[i] = allUsers[referrals[i]].uniqueId;
        }

        return referralUniqueIds;
    }

    function getDirectReferralsCount(string memory uniqueId)
        external
        view
        returns (uint256)
    {
        address userAddress = userAddressByUniqueId[uniqueId];
        require(userAddress != address(0), "User not found");

        return allUsers[userAddress].referrals.length;
    }

    function getTotalReferralCount(address user)
        external
        view
        returns (uint256 directReferrals, uint256 totalReferrals)
    {
        directReferrals = allUsers[user].referrals.length;
        totalReferrals = countTotalReferrals(user);
    }

    function countTotalReferrals(address user) internal view returns (uint256) {
        uint256 totalReferrals = allUsers[user].referrals.length;

        for (uint256 i = 0; i < allUsers[user].referrals.length; i++) {
            totalReferrals += countTotalReferrals(allUsers[user].referrals[i]);
        }

        return totalReferrals;
    }
}

    // function getCompleteTeam(string memory uniqueId)
    //     external
    //     view
    //     returns (string[] memory)
    // {
    //     address userAddress = userAddressByUniqueId[uniqueId];
    //     require(userAddress != address(0), "User not found");

    //     uint256 totalReferrals = countTotalReferrals(userAddress);
    //     string[] memory teamUniqueIds = new string[](totalReferrals + 1);
    //     uint256 currentIndex = 0;

    //     traverseTeam(userAddress, teamUniqueIds, currentIndex);
    //     return teamUniqueIds;
    // }

    // function traverseTeam(
    //     address currentAddress,
    //     string[] memory teamUniqueIds,
    //     uint256 currentIndex
    // ) internal view {
    //     teamUniqueIds[currentIndex] = allUsers[currentAddress].uniqueId;
    //     currentIndex++;

    //     for (
    //         uint256 i = 0;
    //         i < allUsers[currentAddress].referrals.length;
    //         i++
    //     ) {
    //         traverseTeam(
    //             allUsers[currentAddress].referrals[i],
    //             teamUniqueIds,
    //             currentIndex
    //         );
    //     }
    // }

