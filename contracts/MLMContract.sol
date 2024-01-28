// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MLMContract is Initializable, OwnableUpgradeable, ERC20Upgradeable {
    uint256[] public packagePrices;
    mapping(address => uint256) public userPackages;
    mapping(address => address) public upline; // Mapping to store upline for each user
    mapping(address => address[]) public downlines; // Mapping to store downlines for each user

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

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    address public usdtToken; // USDT token address

    function initialize(address initialOwner, address _usdtToken) external initializer {
        __Ownable_init(initialOwner);
        usdtToken = _usdtToken;

        packagePrices.push(5 * 10**6);     // 5 USDT
        packagePrices.push(8 * 10**6);     // 8 USDT
        packagePrices.push(14 * 10**6);    // 14 USDT
        packagePrices.push(28 * 10**6);    // 28 USDT
        packagePrices.push(50 * 10**6);    // 50 USDT
        packagePrices.push(98 * 10**6);    // 98 USDT
        packagePrices.push(194 * 10**6);   // 194 USDT
        packagePrices.push(386 * 10**6);   // 386 USDT
        packagePrices.push(770 * 10**6);   // 770 USDT
        packagePrices.push(1538 * 10**6);  // 1538 USDT
        packagePrices.push(3072 * 10**6);  // 3072 USDT
        packagePrices.push(6146 * 10**6);  // 6146 USDT

        // Set initial upline addresses
        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());
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

        // Set uplines 2 to 5
        upline2 = payable(userUpline);
        upline3 = payable(upline[userUpline]);
        upline4 = payable(upline[upline3]);
        upline5 = payable(upline[upline4]);
    }

    function purchasePackage(uint256 packageIndex, address upline1Address) external payable {
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

        // Add the user to the downlines of their upline
        downlines[upline1Address].push(msg.sender);

        // Set upline addresses
        updateAndSetDistributionAddresses(upline1Address);

        // Distribute 2 ETH among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        // Distribute the remaining amount among upline and downlines
        distribution(packagePrice - 2 * 10**6);

        // Remove the user from the downlines of their previous upline
        if (currentUpline != address(0)) {
            address[] storage previousDownlines = downlines[currentUpline];
            for (uint256 i = 0; i < previousDownlines.length; i++) {
                if (previousDownlines[i] == msg.sender) {
                    // Swap with the last element and pop to remove the user
                    previousDownlines[i] = previousDownlines[previousDownlines.length - 1];
                    previousDownlines.pop();
                    break;
                }
            }
        }

        userPackages[msg.sender] = packageIndex;

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

    function distribution(uint256 remainingPackageAmount) internal {
        uint256 amountUpline = remainingPackageAmount / 2;

        // Transfer USDT to upline addresses
        IERC20(usdtToken).transfer(
            upline1,
            amountUpline
        );
        IERC20(usdtToken).transfer(
            upline2,
            remainingPackageAmount - amountUpline
        );
    }

    function getUserPackage(address user) external view returns (uint256) {
        return userPackages[user];
    }
}
