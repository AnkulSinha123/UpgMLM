// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract Registration is Initializable, OwnableUpgradeable {
    struct UserInfo {
        address referrer;
        address[] referrals;
        address[] levels; // This is the levels field
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

    function getTotalAddressesJoined(address user)
        external
        view
        returns (uint256)
    {
        address[] memory levels = allUsers[user].referrals;
        uint256 totalCount = levels.length;

        for (uint256 i = 0; i < levels.length; i++) {
            totalCount += allUsers[levels[i]].referrals.length;
        }

        return totalCount;
    }

    function getDirectReferralsCount(address user)
        external
        view
        returns (uint256)
    {
        return allUsers[user].referrals.length;
    }

    function GetAllReferralsCount(address user)
        external
        view
        returns (uint256)
    {
        uint256 totalAddressesJoined = this.getTotalAddressesJoined(user);
        uint256 directReferralsCount = this.getDirectReferralsCount(user);

        if (totalAddressesJoined >= directReferralsCount) {
            return totalAddressesJoined - directReferralsCount;
        } else {
            // Handle the case where totalAddressesJoined is unexpectedly less than directReferralsCount
            return 0;
        }
    }

    function excludeAddresses(
        address[] memory source,
        address[] memory exclusionList
    ) internal pure returns (address[] memory) {
        uint256 sourceLength = source.length;
        uint256 exclusionLength = exclusionList.length;

        if (exclusionLength == 0) {
            return source;
        }

        address[] memory result = new address[](sourceLength);
        uint256 resultIndex = 0;

        for (uint256 i = 0; i < sourceLength; i++) {
            bool exclude = false;

            for (uint256 j = 0; j < exclusionLength; j++) {
                if (source[i] == exclusionList[j]) {
                    exclude = true;
                    break;
                }
            }

            if (!exclude) {
                result[resultIndex] = source[i];
                resultIndex++;
            }
        }

        // Resize the result array to the correct length
        assembly {
            mstore(result, resultIndex)
        }

        return result;
    }

    // Add this function to exclude strings from an array of strings
    function excludeStrings(
        string[] memory source,
        string[] memory exclusionList
    ) internal pure returns (string[] memory) {
        uint256 sourceLength = source.length;
        uint256 exclusionLength = exclusionList.length;

        if (exclusionLength == 0) {
            return source;
        }

        string[] memory result = new string[](sourceLength);
        uint256 resultIndex = 0;

        for (uint256 i = 0; i < sourceLength; i++) {
            bool exclude = false;

            for (uint256 j = 0; j < exclusionLength; j++) {
                if (
                    keccak256(abi.encodePacked(source[i])) ==
                    keccak256(abi.encodePacked(exclusionList[j]))
                ) {
                    exclude = true;
                    break;
                }
            }

            if (!exclude) {
                result[resultIndex] = source[i];
                resultIndex++;
            }
        }

        // Resize the result array to the correct length
        assembly {
            mstore(result, resultIndex)
        }

        return result;
    }

    // Modify the getReferralsByLevel function
    function getReferralsByLevel(address user, uint256 level)
        public
        returns (string[] memory)
    {
        require(level > 0 && level <= 5, "Invalid level");

        // Get referrals at the specified level
        address[] memory referralAddresses = getReferralsAtLevel(user, level);
        string[] memory referralUniqueIds = new string[](
            referralAddresses.length
        );

        // Convert referral addresses to uniqueIds
        for (uint256 i = 0; i < referralAddresses.length; i++) {
            referralUniqueIds[i] = allUsers[referralAddresses[i]].uniqueId;
        }

        // Eliminate addresses from the previous level
        if (level > 1) {
            address[] memory previousLevelReferrals = getReferralsAtLevel(
                user,
                level - 1
            );

            // Convert previous level referral addresses to uniqueIds
            string[] memory previousLevelUniqueIds = new string[](
                previousLevelReferrals.length
            );
            for (uint256 i = 0; i < previousLevelReferrals.length; i++) {
                previousLevelUniqueIds[i] = allUsers[previousLevelReferrals[i]]
                    .uniqueId;
            }

            // Exclude previous level referrals from the current level referrals
            referralUniqueIds = excludeStrings(
                referralUniqueIds,
                previousLevelUniqueIds
            );
        }

        // Clear data for levels lower than or equal to the requested level
        clearDataForLowerLevels(user, level);

        // Store addresses from the current level for future reference
        storeAddressesForLevel(user, level, referralAddresses);

        return referralUniqueIds;
    }

    function getReferralsByLevelCount(address user, uint256 level)
        external
        returns (uint256)
    {
        string[] memory abc = getReferralsByLevel(user, level);
        uint256 xyz = abc.length;

        return xyz;
    }

    function storeAddressesForLevel(
        address user,
        uint256 level,
        address[] memory addresses
    ) internal {
        UserInfo storage userInfo = allUsers[user];

        // Store addresses for the specified level
        userInfo.levels = addresses;
    }

    function getReferralsAtLevel(address user, uint256 level)
        internal
        view
        returns (address[] memory)
    {
        address[] memory currentLevelReferrals = allUsers[user].referrals;

        for (uint256 i = 1; i < level; i++) {
            currentLevelReferrals = getNextLevelReferrals(
                currentLevelReferrals
            );
        }

        return currentLevelReferrals;
    }

    function getNextLevelReferrals(address[] memory users)
        internal
        view
        returns (address[] memory)
    {
        address[] memory nextLevelReferrals;

        for (uint256 i = 0; i < users.length; i++) {
            address[] memory currentLevelReferrals = getDirectReferrals(
                users[i]
            );

            nextLevelReferrals = appendToArray(
                nextLevelReferrals,
                currentLevelReferrals
            );
        }

        return nextLevelReferrals;
    }

    function getDirectReferrals(address user)
        internal
        view
        returns (address[] memory)
    {
        return allUsers[user].referrals;
    }

    function appendToArray(address[] memory array, address[] memory elements)
        internal
        pure
        returns (address[] memory)
    {
        address[] memory newArray = new address[](
            array.length + elements.length
        );
        for (uint256 i = 0; i < array.length; i++) {
            newArray[i] = array[i];
        }
        for (uint256 i = 0; i < elements.length; i++) {
            newArray[array.length + i] = elements[i];
        }
        return newArray;
    }

    function clearDataForLowerLevels(address user, uint256 level) internal {
        UserInfo storage userInfo = allUsers[user];

        // Clear data for levels lower than the requested level
        for (uint256 i = 1; i <= level; i++) {
            // Check if the user is registered to avoid unnecessary clearing
            if (userInfo.isRegistered) {
                userInfo.levels = new address[](0);
                user = userInfo.referrer;
                userInfo = allUsers[user];
            } else {
                // Break if the referrer is not registered
                break;
            }
        }
    }
}
