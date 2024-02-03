// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;


import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "./Registration.sol";



contract Pro_Power_Matrix is
    Initializable,
    OwnableUpgradeable,
    ERC20Upgradeable,
    Registration
{
    mapping(address => uint256) public userPackages;
    mapping(address => address) public upline; // Mapping to store upline for each user
    mapping(uint256 => mapping(address => address[])) public downlines;
    mapping(uint256 => mapping(address => address[]))
        public secondLayerDownlines;

    // Add a struct to hold the package information
    struct Package {
        uint256 price;
        uint256 maxDirectDownlines;
        uint256 maxSecondaryDownlines;
    }

    // Declare an array to store package information
    Package[] public packageInfo;

    event PackagePurchased(
        address indexed user,
        uint256 packageIndex,
        uint256 price
    );

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;

    address payable public RoyaltyContract;

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    address public usdtToken; // USDT token address

    function initialize(
        address initialOwner,
        address _usdtToken,
        address _royalty
    ) external initializer {
        __Ownable_init(initialOwner);
        usdtToken = _usdtToken;

        packageInfo.push(Package(5 * 10**6, 4, 16));
        packageInfo.push(Package(8 * 10**6, 4, 16));
        packageInfo.push(Package(14 * 10**6, 4, 16));
        packageInfo.push(Package(28 * 10**6, 4, 16));
        packageInfo.push(Package(50 * 10**6, 4, 16));
        packageInfo.push(Package(98 * 10**6, 4, 16));
        packageInfo.push(Package(194 * 10**6, 4, 16));
        packageInfo.push(Package(386 * 10**6, 4, 16));
        packageInfo.push(Package(770 * 10**6, 4, 16));
        packageInfo.push(Package(1538 * 10**6, 4, 16));
        packageInfo.push(Package(3072 * 10**6, 4, 16));
        packageInfo.push(Package(6146 * 10**6, 4, 16));

        // Set initial upline addresses
        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());

        RoyaltyContract = payable(_royalty);
    }

    receive() external payable {}

    function updateAndSetDistributionAddresses(address currentUpline) internal {
        address userUpline = currentUpline;

        // Iterate through uplines until a qualified upline is found
        while (userUpline != address(0)) {
            if (userPackages[userUpline] >= userPackages[msg.sender]) {
                break; // Found a qualified upline
            }

            userUpline = upline[userUpline]; // Move up to the next upline
        }

        // If no qualified upline is found, set it to the contract owner
        if (userUpline == address(0)) {
            userUpline = payable(owner());
        }

        // Set uplines 1 to 5
        upline1 = payable(userUpline);
        upline2 = payable(upline[upline1]);
        upline3 = payable(upline[upline2]);
        upline4 = payable(upline[upline3]);
        upline5 = payable(upline[upline4]);

        // If upline2, upline3, upline4, or upline5 are not set, set them to the contract owner
        if (upline2 == address(0)) {
            upline2 = payable(owner());
        }

        if (upline3 == address(0)) {
            upline3 = payable(owner());
        }

        if (upline4 == address(0)) {
            upline4 = payable(owner());
        }

        if (upline5 == address(0)) {
            upline5 = payable(owner());
        }
    }

    function purchasePackage(uint256 packageIndex, address upline1Address)
        external
        payable
    {
        require(packageIndex < packageInfo.length, "Invalid package index");

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            currentPackageIndex == 0 || packageIndex == currentPackageIndex + 1,
            "Must purchase packages sequentially"
        );

        uint256 packagePrice = packageInfo[packageIndex].price;
        require(
            msg.value >= packagePrice,
            "Insufficient USDT sent for package purchase"
        );

        // Check if the user is registered
        require(allUsers[msg.sender].isRegistered, "User is not registered");

        // Check the maximum allowed direct downlines and secondary downlines
        require(
            secondLayerDownlines[packageIndex][upline1Address].length <
                packageInfo[packageIndex].maxSecondaryDownlines,
            "Exceeded secondary downlines limit"
        );

        // Update upline and downlines mappings
        upline[msg.sender] = upline1Address;

        // Check if the specified upline already has 4 downlines
        if (
            downlines[packageIndex][upline1Address].length <
            packageInfo[packageIndex].maxDirectDownlines
        ) {
            downlines[packageIndex][upline1Address].push(msg.sender);
            upline[msg.sender] = upline1Address;
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][upline1Address].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][
                    upline1Address
                ][i];
                if (
                    downlines[packageIndex][downlineAddress].length <
                    packageInfo[packageIndex].maxDirectDownlines
                ) {
                    downlines[packageIndex][downlineAddress].push(msg.sender);
                    upline[msg.sender] = downlineAddress;
                }
            }
        }

        address current = upline[msg.sender];

        // Set upline addresses
        updateAndSetDistributionAddresses(current);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        // Distribute the remaining amount among upline and downlines
        uint256 remainingAmount = packagePrice - 2 * 10**6;

        // Transfer USDT to upline1
        payable(upline1).transfer(remainingAmount / 2);

        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            upline2
        ];
        uint256 i = secondLayer.length;

        // Assuming secondLayer has at least 16 elements
        if (secondLayer.length >= 16) {
            if (1 <= i && i <= 3) {
                // Distribute to RoyaltyContract for the first 3 downlines
                payable(RoyaltyContract).transfer(remainingAmount / 2);
            } else if (4 <= i && i <= 14) {
                // Distribute to upline2 for downlines 4 to 13
                payable(upline2).transfer(remainingAmount / 2);
            } else if (15 <= i && i <= 16) {
                // Distribute to upline1 and upline2 for downlines 14 and 15
                payable(upline1).transfer(remainingAmount / 4);
                payable(upline2).transfer(remainingAmount / 4);
            }
        }

        // Remove the user from the downlines of their previous upline
        userPackages[msg.sender] = packageIndex;

        // Add the user to the second layer downlines of their upline for the specific package
        if (upline[upline1Address] != address(0)) {
            secondLayerDownlines[packageIndex][upline[upline1Address]].push(
                msg.sender
            );

            if (
                secondLayerDownlines[packageIndex][upline[upline1Address]]
                    .length == packageInfo[packageIndex].maxSecondaryDownlines
            ) {
                // Clear downlines and secondLayerDownlines for the upline and specific package
                clearDownlines(upline[upline1Address]);
                clearSecondLayerDownlines(upline[upline1Address]);
            }
        }

        emit PackagePurchased(msg.sender, packageIndex, packagePrice);
    }

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * 10**6; // 2 USDT

        // Transfer USDT to levels
        IERC20(usdtToken).transfer(
            upline1,
            (usdtToDistribute * upline1_PERCENTAGE) / 100
        );
        IERC20(usdtToken).transfer(
            upline2,
            (usdtToDistribute * upline2_PERCENTAGE) / 100
        );
        IERC20(usdtToken).transfer(
            upline3,
            (usdtToDistribute * upline3_PERCENTAGE) / 100
        );
        IERC20(usdtToken).transfer(
            upline4,
            (usdtToDistribute * upline4_PERCENTAGE) / 100
        );
        IERC20(usdtToken).transfer(
            upline5,
            (usdtToDistribute * upline5_PERCENTAGE) / 100
        );
    }

    function getUserPackage(address user) external view returns (uint256) {
        return userPackages[user];
    }

    function getSecondLayerDownlines(address user)
        external
        view
        returns (address[] memory)
    {
        return secondLayerDownlines[userPackages[user]][user];
    }

    // Function to clear downlines for the specified upline and package
    function clearDownlines(address uplineAddress) internal onlyOwner {
        address[] storage directDownlines = downlines[
            userPackages[uplineAddress]
        ][uplineAddress];

        // Clear downlines for the specified upline and package
        delete downlines[userPackages[uplineAddress]][uplineAddress];

        // Clear userPackages for downlines of the specified upline and package
        for (uint256 i = 0; i < directDownlines.length; i++) {
            delete userPackages[directDownlines[i]];
        }
    }

    // Function to clear secondLayerDownlines for the specified upline and package
    function clearSecondLayerDownlines(address uplineAddress)
        internal
        onlyOwner
    {
        delete secondLayerDownlines[userPackages[uplineAddress]][uplineAddress];

        address[] storage secondLayer = secondLayerDownlines[
            userPackages[uplineAddress]
        ][uplineAddress];
        for (uint256 i = 0; i < secondLayer.length; i++) {
            delete userPackages[secondLayer[i]];
        }
    }

    function getTotalPurchases() external view returns (uint256) {
        uint256 totalPurchases = 0;

        // Iterate through all users
        for (uint256 i = 0; i < packageInfo.length; i++) {
            address[] storage userAddresses = downlines[i][owner()];

            // Iterate through downlines of the owner (contract creator)
            for (uint256 j = 0; j < userAddresses.length; j++) {
                address user = userAddresses[j];
                totalPurchases += packageInfo[userPackages[user]].price;
            }
        }

        return totalPurchases;
    }

    function getTop10Earners()
        external
        view
        returns (
            address[10] memory topEarners,
            uint256[10] memory highestEarnings
        )
    {
        for (uint256 i = 0; i < packageInfo.length; i++) {
            address[] storage userAddresses = downlines[i][owner()];

            for (uint256 j = 0; j < userAddresses.length; j++) {
                address user = userAddresses[j];
                uint256 userEarnings = calculateUserEarnings(user);

                // Check if the user should be included in the top earners list
                for (uint256 k = 0; k < 10; k++) {
                    if (userEarnings > highestEarnings[k]) {
                        // Shift down the existing earners to make room for the new one
                        for (uint256 l = 9; l > k; l--) {
                            topEarners[l] = topEarners[l - 1];
                            highestEarnings[l] = highestEarnings[l - 1];
                        }

                        // Insert the new top earner
                        topEarners[k] = user;
                        highestEarnings[k] = userEarnings;

                        // Break the inner loop as the user is already inserted
                        break;
                    }
                }
            }
        }

        return (topEarners, highestEarnings);
    }

    function calculateUserEarnings(address user)
        internal
        view
        returns (uint256)
    {
        uint256 totalEarnings = 0;

        // Add user's direct and secondary earnings
        totalEarnings += ((2 * 10**6) * upline1_PERCENTAGE) / 100; // Direct earnings
        totalEarnings += ((2 * 10**6 )* upline2_PERCENTAGE) / 100; // Secondary earnings (upline2)

        // Add additional earnings based on your business logic

        return totalEarnings;
    }

    function addUserToDirectDownlineAndProvidePackage(
        address user,
        uint256 packageIndex
    ) external onlyOwner {
        require(packageIndex < packageInfo.length, "Invalid package index");

        // Ensure the package index is valid

        // Check if the user is not already in the downline
        require(upline[user] == address(0), "User is already in the downline");

        // Add the user to the direct downline
        upline[user] = owner();

        // Update user's package index
        userPackages[user] = packageIndex;

        // Emit an event for the package purchase
        emit PackagePurchased(
            user,
            packageIndex,
            packageInfo[packageIndex].price
        );
    }

    function ownerBuysAllPackages() external onlyOwner {
        // Iterate through all packages and purchase them for the owner
        for (uint256 i = 0; i < packageInfo.length; i++) {
            // Update user's package index
            userPackages[owner()] = i;

            // Emit an event for the package purchase
            emit PackagePurchased(owner(), i, packageInfo[i].price);
        }
    }


}
