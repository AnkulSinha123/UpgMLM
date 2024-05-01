// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Registration{
    address public owner;

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    mapping(address => UserInfo) public allUsers;
    mapping(string => address) public userAddressByUniqueId;
    uint256 public totalUsers;

    event UserRegistered(
        address indexed user,
        address indexed referrer,
        string uniqueId
    );

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
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
            referrerInfo.isRegistered || referrer == owner,
            "Not registered"
        );
        require(!user.isRegistered, "Already registered");

        user.userUniqueId = GetIdFromAddress(msg.sender);
        user.referrer = referrer;
        user.isRegistered = true;
        referrerInfo.referrals.push(msg.sender);

        userAddressByUniqueId[user.userUniqueId] = msg.sender;
        totalUsers++;

        emit UserRegistered(msg.sender, referrer, user.userUniqueId);
    }

    function registerByOwner() external onlyOwner {
        UserInfo storage ownerInfo = allUsers[owner];

        require(!ownerInfo.isRegistered, "Already registered");

        ownerInfo.userUniqueId = GetIdFromAddress(owner);
        ownerInfo.referrer = owner;
        ownerInfo.isRegistered = true;
        ownerInfo.referrals.push(owner);
        userAddressByUniqueId[ownerInfo.userUniqueId] = owner;
        totalUsers++;

        emit UserRegistered(owner, address(0), ownerInfo.userUniqueId);
    }

    function findReferrerByUniqueId(string memory referrerUniqueId)
        public
        view
        returns (address)
    {
        address referrerAddress = userAddressByUniqueId[referrerUniqueId];
        require(referrerAddress != address(0), "Referrer not found");
        return referrerAddress;
    }

    function getUserInfo(address userAddress)
        external
        view
        returns (UserInfo memory)
    {
        return allUsers[userAddress];
    }

    function getDirectReferrals(address user)
        external
        view
        returns (address[] memory)
    {
        return allUsers[user].referrals;
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