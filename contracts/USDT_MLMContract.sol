// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract USDT_MLMContract is Initializable, OwnableUpgradeable, ERC20Upgradeable {
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

    address payable public RoyaltyBonus;

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    address public usdtToken; // USDT token address

    function initialize(address initialOwner,address _usdtToken,address _royalty)
        external
        initializer
    {
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

        RoyaltyBonus = payable(_royalty);
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
        distribute2USDT();

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

        address[] storage secondLayer = secondLayerDownlines[upline2];
        uint256 i = secondLayer.length;

        // Assuming secondLayer has at least 16 elements
       if (secondLayer.length >= 16) {
            if (1 <= i && i <= 3) {
                IERC20(usdtToken).transfer(RoyaltyBonus, remainingPackageAmount - amountUpline);
            } else if (4 <= i && i <= 14) {
                IERC20(usdtToken).transfer(upline2, remainingPackageAmount - amountUpline);
            } else if (15 <= i && i <= 16) {
                IERC20(usdtToken).transfer(upline1, (remainingPackageAmount - amountUpline) / 2);
                IERC20(usdtToken).transfer(upline2, (remainingPackageAmount - amountUpline) / 2);
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
