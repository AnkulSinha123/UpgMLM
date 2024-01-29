//. 5000000000000000000
// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract Ether_MLMContract is Initializable, OwnableUpgradeable, ERC20Upgradeable {
    uint256[] public packagePrices;
    mapping(address => uint256) public userPackages;
    mapping(address => address) public upline; // Mapping to store upline for each user
    mapping(address => address[]) public downlines; // Mapping to store downlines for each user
    mapping(address => address[]) public secondLayerDownlines; // Mapping to store second layer downlines for each user

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

        packagePrices.push(5 ether); // 5 ETH
        packagePrices.push(8 ether); // 8 ETH
        packagePrices.push(14 ether); // 14 ETH
        packagePrices.push(28 ether); // 28 ETH
        packagePrices.push(50 ether); // 50 ETH
        packagePrices.push(98 ether); // 98 ETH
        packagePrices.push(194 ether); // 194 ETH
        packagePrices.push(386 ether); // 386 ETH
        packagePrices.push(770 ether); // 770 ETH
        packagePrices.push(1538 ether); // 1538 ETH
        packagePrices.push(3072 ether); // 3072 ETH
        packagePrices.push(6146 ether); // 6146 ETH

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
    }

    function purchasePackage(uint256 packageIndex, address upline1Address)
        external
        payable
    {
        require(packageIndex < packagePrices.length, "Invalid package index");

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            currentPackageIndex == 0 || packageIndex == currentPackageIndex + 1,
            "Must purchase packages sequentially"
        );

        uint256 packagePrice = packagePrices[packageIndex];
        require(
            msg.value >= packagePrice,
            "Insufficient ETH sent for package purchase"
        );

        // Update upline and downlines mappings
        address currentUpline = upline[msg.sender];
        upline[msg.sender] = upline1Address;

        //Upline must have less than four direct downlines
        require(downlines[upline1Address].length < 4, "Already 4 downlines") ;
        downlines[upline1Address].push(msg.sender);

        // Set upline addresses
        updateAndSetDistributionAddresses(upline1Address);

        // Distribute 2 ETH among levels 1 to 5 (deducted from the package price)
        distribute2ETH();

        // Distribute the remaining amount among upline and downlines
        distribution(packagePrice - 2 ether);

        // Remove the user from the downlines of their previous upline
        if (currentUpline != address(0)) {
            address[] storage previousDownlines = downlines[currentUpline];
            for (uint256 i = 0; i < previousDownlines.length; i++) {
                if (previousDownlines[i] == msg.sender) {
                    // Swap with the last element and pop to remove the user
                    previousDownlines[i] = previousDownlines[
                        previousDownlines.length - 1
                    ];
                    previousDownlines.pop();
                    break;
                }
            }
        }

        userPackages[msg.sender] = packageIndex;

        // Add the user to the second layer downlines of their upline
        if (upline[upline1Address] != address(0)) {
            secondLayerDownlines[upline[upline1Address]].push(msg.sender);

            // Check if the secondLayerDownlines count reaches 16
            if (secondLayerDownlines[upline[upline1Address]].length == 16) {
                // Clear downlines and secondLayerDownlines for the upline
                clearDownlines(upline[upline1Address]);
                clearSecondLayerDownlines(upline[upline1Address]);
            }
        }

        emit PackagePurchased(msg.sender, packageIndex, packagePrice);
    }

    function distribute2ETH() internal {
        uint256 ethToDistribute = 2 ether; // 2 ETH

        // Transfer ETH to levels
        payable(upline1).transfer((ethToDistribute * upline1_PERCENTAGE) / 100);
        payable(upline2).transfer((ethToDistribute * upline2_PERCENTAGE) / 100);
        payable(upline3).transfer((ethToDistribute * upline3_PERCENTAGE) / 100);
        payable(upline4).transfer((ethToDistribute * upline4_PERCENTAGE) / 100);
        payable(upline5).transfer((ethToDistribute * upline5_PERCENTAGE) / 100);
    }

    function distribution(uint256 remainingPackageAmount) internal {
        uint256 amountUpline = remainingPackageAmount / 2;

        // Transfer ETH to upline1
        payable(upline1).transfer(amountUpline);

        address[] storage secondLayer = secondLayerDownlines[upline2];
        uint256 i = secondLayer.length;

        // Assuming secondLayer has at least 16 elements
        if (secondLayer.length >= 16) {
            if (1 <= i && i <= 3) {
                // Distribute to RoyaltyContract for the first 3 downlines
                payable(RoyaltyContract).transfer(
                    remainingPackageAmount - amountUpline
                );
            } else if (4 <= i && i <= 14) {
                // Distribute to upline2 for downlines 4 to 13
                payable(upline2).transfer(
                    remainingPackageAmount - amountUpline
                );
            } else if (15 <= i && i <= 16) {
                // Distribute to upline1 and upline2 for downlines 14 and 15
                payable(upline1).transfer(
                    (remainingPackageAmount - amountUpline) / 2
                );
                payable(upline2).transfer(
                    (remainingPackageAmount - amountUpline) / 2
                );
            }
        }
    }

    function getUserPackage(address user) external view returns (uint256) {
        return userPackages[user];
    }

    function getSecondLayerDownlines(address user)
        external
        view
        returns (address[] memory)
    {
        return secondLayerDownlines[user];
    }

    function clearDownlines(address uplineAddress) internal onlyOwner {
        // Clear downlines for the specified upline
        delete downlines[uplineAddress];

        // Clear userPackages for downlines of the specified upline
        address[] storage directDownlines = downlines[uplineAddress];
        for (uint256 i = 0; i < directDownlines.length; i++) {
            delete userPackages[directDownlines[i]];
        }
    }

    function clearSecondLayerDownlines(address uplineAddress)
        internal
        onlyOwner
    {
        // Clear secondLayerDownlines for the specified upline
        delete secondLayerDownlines[uplineAddress];

        // Clear userPackages for secondLayerDownlines of the specified upline
        address[] storage secondLayer = secondLayerDownlines[uplineAddress];
        for (uint256 i = 0; i < secondLayer.length; i++) {
            delete userPackages[secondLayer[i]];
        }
    }
}