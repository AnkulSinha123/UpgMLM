// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Registration is Initializable, OwnableUpgradeable {
    struct UserInfo {
        address referrer;
        address[] referrals;
        address[] levels;
        bool isRegistered;
        string uniqueId;
    }

    mapping(address => UserInfo) private allUsers;
    mapping(string => address) private userAddressByUniqueId;
    uint256 public totalUsers;

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
        address referrer = findReferrerByUniqueId(referrerUniqueId);

        UserInfo storage user = allUsers[msg.sender];
        UserInfo storage referrerInfo = allUsers[referrer];

        require(
            referrerInfo.isRegistered || referrer == owner(),
            "Not registered"
        );
        require(!user.isRegistered, "Already registered");

        user.uniqueId = getUniqueId(msg.sender);
        user.referrer = referrer;
        user.isRegistered = true;
        referrerInfo.referrals.push(msg.sender);

        // Add the user to level 1 of the referrer's levels
        allUsers[referrer].levels.push(msg.sender);

        userAddressByUniqueId[user.uniqueId] = msg.sender;
        totalUsers++;

        emit UserRegistered(msg.sender, referrer);
    }

    function registerByOwner() external onlyOwner {
        UserInfo storage ownerInfo = allUsers[owner()];

        require(!ownerInfo.isRegistered, "Already registered");

        ownerInfo.uniqueId = getUniqueId(owner());
        ownerInfo.referrer = owner();
        ownerInfo.isRegistered = true;
        ownerInfo.referrals.push(owner());

        userAddressByUniqueId[ownerInfo.uniqueId] = owner();
        totalUsers++;

        emit UserRegistered(owner(), address(0));
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

    function getLevelsByUniqueId(address user, uint256 level)
        external
        view
        returns (string[] memory)
    {
        address[] memory levels = allUsers[user].levels;

        require(level > 0 && level <= 5, "Invalid level");

        string[] memory uniqueIds;

        for (uint256 i = 0; i < levels.length; i++) {
            address[] memory currentLevel = allUsers[levels[i]].levels;

            if (level == 1) {
                // Level 1 is the direct referrals
                uniqueIds = appendToStringArray(uniqueIds, getUniqueId(levels[i]));
            } else {
                // Traverse through the levels to find the desired level
                for (uint256 j = 2; j <= level && currentLevel.length > 0; j++) {
                    address[] memory nextLevel;
                    for (uint256 k = 0; k < currentLevel.length; k++) {
                        nextLevel = appendToArray(nextLevel, allUsers[currentLevel[k]].levels);
                    }

                    if (j == level) {
                        for (uint256 k = 0; k < nextLevel.length; k++) {
                            uniqueIds = appendToStringArray(uniqueIds, getUniqueId(nextLevel[k]));
                        }
                    }

                    currentLevel = nextLevel;
                }
            }
        }

        return uniqueIds;
    }

    function getTotalAddressesJoined(address user) external view returns (uint256) {
        address[] memory levels = allUsers[user].levels;

        uint256 totalCount = levels.length;

        for (uint256 i = 0; i < levels.length; i++) {
            address[] memory currentLevel = allUsers[levels[i]].levels;

            for (uint256 j = 0; j < currentLevel.length; j++) {
                totalCount += allUsers[currentLevel[j]].levels.length;
            }
        }

        return totalCount;
    }

    function appendToArray(address[] memory array, address[] memory elements)
        internal
        pure
        returns (address[] memory)
    {
        address[] memory newArray = new address[](array.length + elements.length);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        for (uint256 i = 0; i < elements.length; i++) {
            newArray[array.length + i] = elements[i];
        }
        return newArray;
    }

    function appendToStringArray(string[] memory array, string memory element)
        internal
        pure
        returns (string[] memory)
    {
        string[] memory newArray = new string[](array.length + 1);
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        newArray[array.length] = element;
        return newArray;
    }
}
