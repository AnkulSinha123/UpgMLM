// // SPDX-License-Identifier: MIT
// pragma solidity ^0.8.0;

// import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
// import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
// import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

// contract MLMContract is Initializable, OwnableUpgradeable, ERC20Upgradeable {
//     uint256[] public packagePrices;
//     mapping(address => uint256) public userPackages;
//     mapping(address => address) public upline; // Mapping to store upline for each user
//     mapping(address => address[]) public downlines; // Mapping to store downlines for each user

//     event PackagePurchased(
//         address indexed user,
//         uint256 packageIndex,
//         uint256 price
//     );

//     // USDT token address
//     address public usdtToken;

//     // Declare payable addresses for upline
//     address payable public upline1;
//     address payable public upline2;
//     address payable public upline3;
//     address payable public upline4;
//     address payable public upline5;

//     // Constants for distribution percentages
//     uint256 private constant upline1_PERCENTAGE = 40;
//     uint256 private constant upline2_PERCENTAGE = 25;
//     uint256 private constant upline3_PERCENTAGE = 15;
//     uint256 private constant upline4_PERCENTAGE = 10;
//     uint256 private constant upline5_PERCENTAGE = 10;

//     function initialize(address initialOwner, address _usdtToken)
//         external
//         initializer
//     {
//         __Ownable_init(initialOwner);
//         usdtToken = _usdtToken;

//         packagePrices.push(5 * 10**6); // 5 USDT
//         packagePrices.push(8 * 10**6); // 8 USDT
//         packagePrices.push(14 * 10**6); // 14 USDT
//         packagePrices.push(28 * 10**6); // 28 USDT
//         packagePrices.push(50 * 10**6); // 50 USDT
//         packagePrices.push(98 * 10**6); // 98 USDT
//         packagePrices.push(194 * 10**6); // 194 USDT
//         packagePrices.push(386 * 10**6); // 386 USDT
//         packagePrices.push(770 * 10**6); // 770 USDT
//         packagePrices.push(1538 * 10**6); // 1538 USDT
//         packagePrices.push(3072 * 10**6); // 3072 USDT
//         packagePrices.push(6146 * 10**6); // 6146 USDT
//     }

//     receive() external payable {}

    

//     function distribute2USDT() internal {
//         uint256 usdtToDistribute = 2 * 10**6; // 2 USDT

//         // Transfer USDT to levels
//         IERC20(usdtToken).transfer(
//             upline1,
//             (usdtToDistribute * upline1_PERCENTAGE) / 100
//         );
//         IERC20(usdtToken).transfer(
//             upline2,
//             (usdtToDistribute * upline2_PERCENTAGE) / 100
//         );
//         IERC20(usdtToken).transfer(
//             upline3,
//             (usdtToDistribute * upline3_PERCENTAGE) / 100
//         );
//         IERC20(usdtToken).transfer(
//             upline4,
//             (usdtToDistribute * upline4_PERCENTAGE) / 100
//         );
//         IERC20(usdtToken).transfer(
//             upline5,
//             (usdtToDistribute * upline5_PERCENTAGE) / 100
//         );
//     }

//     function distribution(uint256 remainingPackageAmount) internal {
//         uint256 amountUpline = remainingPackageAmount / 2;

//         // Transfer USDT to upline addresses
//         IERC20(usdtToken).transfer(upline1, amountUpline);
//         IERC20(usdtToken).transfer(
//             upline2,
//             remainingPackageAmount - amountUpline
//         );
//     }

//     function getUserPackage(address user) external view returns (uint256) {
//         return userPackages[user];
//     }

//     function setUplineAddresses(address _upline, address[] calldata _downlines)
//         external
//     {
//         require(_upline != address(0), "Invalid upline address");
//         require(_downlines.length <= 4, "Exceeds maximum allowed downlines");

//         upline[msg.sender] = _upline;
//         downlines[msg.sender] = _downlines;
//     }

//     function withdrawETH(uint256 amount) external {
//         payable(owner()).transfer(amount);
//     }

//     function setDistributionAddresses(address initialUpline) internal {
//     address userUpline = initialUpline;

//     // Iterate through uplines until a qualified upline is found for upline1
//     while (userUpline != address(0)) {
//         if (userPackages[userUpline] >= userPackages[msg.sender]) {
//             break; // Found a qualified upline
//         }

//         userUpline = upline[userUpline]; // Move up to the next upline
//     }

//     // If no qualified upline is found, set it to the contract owner
//     if (userUpline == address(0)) {
//         userUpline = payable(owner());
//     }

//     upline1 = payable(userUpline);

//     // Iterate through uplines to find qualified upline for upline2
//     for (uint256 i = 0; i < 4; i++) {
//         userUpline = upline[upline1];

//         // Iterate through uplines until a qualified upline is found
//         while (userUpline != address(0)) {
//             if (userPackages[userUpline] >= userPackages[msg.sender]) {
//                 break; // Found a qualified upline
//             }

//             userUpline = upline[userUpline]; // Move up to the next upline
//         }

//         // If no qualified upline is found, set it to the contract owner
//         if (userUpline == address(0)) {
//             userUpline = payable(owner());
//         }

//         if (i == 0) {
//             upline2 = payable(userUpline);
//         } else if (i == 1) {
//             upline3 = payable(userUpline);
//         } else if (i == 2) {
//             upline4 = payable(userUpline);
//         } else if (i == 3) {
//             upline5 = payable(userUpline);
//         }
//     }
// }

// }
