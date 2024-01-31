// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Ether_Pro_Power_Matrix is
    Initializable,
    OwnableUpgradeable,
    ERC20Upgradeable
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

    function initialize(address initialOwner, address _royalty)
        external
        initializer
    {
        __Ownable_init(initialOwner);

        packageInfo.push(Package(5 ether, 4, 16));
        packageInfo.push(Package(8 ether, 4, 16));
        packageInfo.push(Package(14 ether, 4, 16));
        packageInfo.push(Package(28 ether, 4, 16));
        packageInfo.push(Package(50 ether, 4, 16));
        packageInfo.push(Package(98 ether, 4, 16));
        packageInfo.push(Package(194 ether, 4, 16));
        packageInfo.push(Package(386 ether, 4, 16));
        packageInfo.push(Package(770 ether, 4, 16));
        packageInfo.push(Package(1538 ether, 4, 16));
        packageInfo.push(Package(3072 ether, 4, 16));
        packageInfo.push(Package(6146 ether, 4, 16));

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
            "Insufficient ETH sent for package purchase"
        );

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

        // Distribute 2 ETH among levels 1 to 5 (deducted from the package price)
        distribute2ETH();

        // Distribute the remaining amount among upline and downlines
        uint256 remainingAmount = packagePrice - 2 ether;

        // Transfer ETH to upline1
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

    function distribute2ETH() public payable {
        uint256 ethToDistribute = 2 ether; // 2 ETH

        // Transfer ETH to levels
        payable(upline1).transfer((ethToDistribute * upline1_PERCENTAGE) / 100);
        payable(upline2).transfer((ethToDistribute * upline2_PERCENTAGE) / 100);
        payable(upline3).transfer((ethToDistribute * upline3_PERCENTAGE) / 100);
        payable(upline4).transfer((ethToDistribute * upline4_PERCENTAGE) / 100);
        payable(upline5).transfer((ethToDistribute * upline5_PERCENTAGE) / 100);
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

    function getTopEarner()
        external
        view
        returns (address topEarner, uint256 highestEarnings)
    {
        for (uint256 i = 0; i < packageInfo.length; i++) {
            address[] storage userAddresses = downlines[i][owner()];

            for (uint256 j = 0; j < userAddresses.length; j++) {
                address user = userAddresses[j];
                uint256 userEarnings = calculateUserEarnings(user);

                if (userEarnings > highestEarnings) {
                    topEarner = user;
                    highestEarnings = userEarnings;
                }
            }
        }

        return (topEarner, highestEarnings);
    }

    function calculateUserEarnings(address user)
        internal
        view
        returns (uint256)
    {
        uint256 totalEarnings = 0;

        // Add user's direct and secondary earnings
        totalEarnings += (2 ether * upline1_PERCENTAGE) / 100; // Direct earnings
        totalEarnings += (2 ether * upline2_PERCENTAGE) / 100; // Secondary earnings (upline2)

        // Add additional earnings based on your business logic

        return totalEarnings;
    }
}
