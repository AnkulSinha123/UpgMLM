// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract LevelandPackage is Initializable, OwnableUpgradeable, ERC20Upgradeable {
    uint256[] public packagePrices;
    mapping(address => uint256) public userPackages;
    mapping(address => address) public upline1;
    mapping(address => address) public upline2;

    event PackagePurchased(address indexed user, uint256 packageIndex, uint256 price);

    // USDT token contract address
    address public usdtTokenAddress;

    // Distribution addresses for levels 1 to 5
    address public level1;
    address public level2;
    address public level3;
    address public level4;
    address public level5;

    // Constants for distribution percentages
    uint256 private constant LEVEL1_PERCENTAGE = 40;
    uint256 private constant LEVEL2_PERCENTAGE = 25;
    uint256 private constant LEVEL3_PERCENTAGE = 15;
    uint256 private constant LEVEL4_PERCENTAGE = 10;
    uint256 private constant LEVEL5_PERCENTAGE = 10;

    function initialize(
    address initialOwner,
    address _usdtTokenAddress,
    address _level1,
    address _level2,
    address _level3,
    address _level4,
    address _level5
) external initializer {
    __Ownable_init(initialOwner);
    usdtTokenAddress = _usdtTokenAddress;
    level1 = _level1;
    level2 = _level2;
    level3 = _level3;
    level4 = _level4;
    level5 = _level5;

    packagePrices.push(5 * (10**18));
    packagePrices.push(8 * (10**18));
    packagePrices.push(14 * (10**18));
    packagePrices.push(28 * (10**18));
    packagePrices.push(50 * (10**18));
    packagePrices.push(98 * (10**18));
    packagePrices.push(194 * (10**18));
    packagePrices.push(386 * (10**18));
    packagePrices.push(770 * (10**18));
    packagePrices.push(1538 * (10**18));
    packagePrices.push(3072 * (10**18));
    packagePrices.push(6146 * (10**18));
}

    receive() external payable {}

    function purchasePackage(uint256 packageIndex) external payable {
        require(packageIndex < packagePrices.length, "Invalid package index");

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(currentPackageIndex == 0 || packageIndex == currentPackageIndex + 1, "Must purchase packages sequentially");

        uint256 packagePrice = packagePrices[packageIndex];
        require(msg.value >= packagePrice, "Insufficient ETH sent for package purchase");

        // Mint MLM tokens to the user
        _mint(msg.sender, packagePrice);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        // Distribute the remaining amount among upline 1 and upline 2 addresses
        distributeUpline(packagePrice - 2);

        userPackages[msg.sender] = packageIndex;

        emit PackagePurchased(msg.sender, packageIndex, packagePrice);
    }

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * (10**6); // Assuming 6 decimal places

        // Calculate distribution amounts based on specified percentages
        uint256 amountLevel1 = (usdtToDistribute * LEVEL1_PERCENTAGE) / 100;
        uint256 amountLevel2 = (usdtToDistribute * LEVEL2_PERCENTAGE) / 100;
        uint256 amountLevel3 = (usdtToDistribute * LEVEL3_PERCENTAGE) / 100;
        uint256 amountLevel4 = (usdtToDistribute * LEVEL4_PERCENTAGE) / 100;
        uint256 amountLevel5 = (usdtToDistribute * LEVEL5_PERCENTAGE) / 100;

        // Transfer USDT to levels
        IERC20(usdtTokenAddress).transfer(level1, amountLevel1);
        IERC20(usdtTokenAddress).transfer(level2, amountLevel2);
        IERC20(usdtTokenAddress).transfer(level3, amountLevel3);
        IERC20(usdtTokenAddress).transfer(level4, amountLevel4);
        IERC20(usdtTokenAddress).transfer(level5, amountLevel5);
    }

    function distributeUpline(uint256 remainingPackageAmount) internal {
        // Split the remaining amount between upline 1 and upline 2 addresses
        uint256 amountUpline1 = remainingPackageAmount / 2;
        uint256 amountUpline2 = remainingPackageAmount - amountUpline1;

        // Transfer ETH to upline addresses
        payable(upline1[msg.sender]).transfer(amountUpline1);
        payable(upline2[msg.sender]).transfer(amountUpline2);
    }

    function getUserPackage(address user) external view returns (uint256) {
        return userPackages[user];
    }

    function setUplineAddresses(address _upline1, address _upline2) external {
        require(_upline1 != address(0) && _upline2 != address(0), "Invalid upline addresses");
        upline1[msg.sender] = _upline1;
        upline2[msg.sender] = _upline2;
    }

    function withdrawETH(uint256 amount) external{
        payable(owner()).transfer(amount);
    }

    function setDistributionAddresses(address _level1, address _level2, address _level3, address _level4, address _level5) external{
        level1 = _level1;
        level2 = _level2;
        level3 = _level3;
        level4 = _level4;
        level5 = _level5;
    }
}