// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "./Registration.sol";

interface RegistrationInterface {
    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    function getUserInfo(address _address)
        external
        view
        returns (UserInfo memory);
}

contract Pro_Power_Matrix is Initializable, OwnableUpgradeable {

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    // Add a struct to hold the package information
    struct Package {
        uint256 price;
        uint256 maxDirectDownlines;
        uint256 maxSecondaryDownlines;
    }

    // Declare an array to store package information
    Package[] public packageInfo;
    
    mapping(address => uint256) public userPackages;
    mapping(address => address) public upline; // Mapping to store upline for each user
    mapping(uint256 => mapping(address => address[])) public downlines;
    mapping(uint256 => mapping(address => address[])) public secondLayerDownlines; 

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;

    address payable public RoyaltyContract;
    address public usdtToken;

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    event PackagePurchased(
        address indexed user,
        uint256 packageIndex,
        uint256 price,
        address upline1,
        address upline2,
        address upline3,
        address upline4,
        address upline5,
        bool royalty,
        bool recycle
    );

    RegistrationInterface public registration;

    function initialize(
        address initialOwner,
        address _usdtToken,
        address _royalty
    ) external initializer {
        __Ownable_init(initialOwner);
        usdtToken = _usdtToken;
        RoyaltyContract = payable(_royalty);

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
    }

    receive() external payable {}

    function setRegistration(address _registrationAddress) external onlyOwner {
        registration = RegistrationInterface(_registrationAddress);
    }

    // Function to fetch user information from Registration contract
    function getUserInfo(address user) public view returns (UserInfo memory) {
        // Call the getUserInfo function from Registration contract
        RegistrationInterface registration = RegistrationInterface(
            registration
        );
        RegistrationInterface.UserInfo memory userInfoInterface = registration
            .getUserInfo(user);

        // Convert the returned UserInfo from Registration contract to local UserInfo struct
        UserInfo memory userInfo;
        userInfo.referrer = userInfoInterface.referrer;
        userInfo.referrals = userInfoInterface.referrals;
        userInfo.isRegistered = userInfoInterface.isRegistered;
        userInfo.userUniqueId = userInfoInterface.userUniqueId;

        return userInfo;
    }

    function updateAndSetDistributionAddresses(
        address currentUpline,
        uint256 packageIndex
    ) internal {
        address userUpline = currentUpline;

        // Initialize upline1 to the contract owner
        upline1 = payable(owner());

        uint256 qualifiedUplinesFound = 0;

        // Iterate through uplines until 5 qualified uplines are found or until the user's package index is greater than or equal to the upline's package index
        while (
            userUpline != address(0) &&
            qualifiedUplinesFound < 5 &&
            userPackages[userUpline] >= packageIndex
        ) {
            qualifiedUplinesFound++;

            if (qualifiedUplinesFound == 1) {
                upline1 = payable(userUpline);
            } else if (qualifiedUplinesFound == 2) {
                upline2 = payable(userUpline);
            } else if (qualifiedUplinesFound == 3) {
                upline3 = payable(userUpline);
            } else if (qualifiedUplinesFound == 4) {
                upline4 = payable(userUpline);
            } else if (qualifiedUplinesFound == 5) {
                upline5 = payable(userUpline);
            }

            userUpline = upline[userUpline]; // Move up to the next upline
        }

        // If upline1, upline2, upline3, upline4, or upline5 are not set, set them to the contract owner
        if (qualifiedUplinesFound < 1) {
            upline1 = payable(owner());
        }

        if (qualifiedUplinesFound < 2) {
            upline2 = payable(owner());
        }

        if (qualifiedUplinesFound < 3) {
            upline3 = payable(owner());
        }

        if (qualifiedUplinesFound < 4) {
            upline4 = payable(owner());
        }

        if (qualifiedUplinesFound < 5) {
            upline5 = payable(owner());
        }
    }

    function purchasePackage(uint256 packageIndex) external {
        require(packageIndex < packageInfo.length, "Invalid package index");

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            currentPackageIndex == 0 || packageIndex == currentPackageIndex + 1,
            "Must purchase packages sequentially"
        );

        uint256 packagePrice = packageInfo[packageIndex].price;

        // Approve USDT transfer from user to contract
        IERC20(usdtToken).approve(address(this), packagePrice);

        // Transfer USDT from the user to the contract
        IERC20(usdtToken).transferFrom(msg.sender, address(this), packagePrice);

        // Check if the user is registered
        require(getUserInfo(msg.sender).isRegistered, "User is not registered");

        address referrerAddress = getUserInfo(msg.sender).referrer;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        // Check if the specified upline already has 4 downlines
        if (
            downlines[packageIndex][referrerAddress].length <
            packageInfo[packageIndex].maxDirectDownlines
        ) {
            downlines[packageIndex][referrerAddress].push(msg.sender);
            upline[msg.sender] = referrerAddress;
            secondLayerDownlines[packageIndex][upline[referrerAddress]].push(
                msg.sender
            );
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][referrerAddress].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][
                    referrerAddress
                ][i];
                if (
                    downlines[packageIndex][downlineAddress].length <
                    packageInfo[packageIndex].maxDirectDownlines
                ) {
                    downlines[packageIndex][downlineAddress].push(msg.sender);
                    upline[msg.sender] = downlineAddress;
                    secondLayerDownlines[packageIndex][referrerAddress].push(
                        msg.sender
                    );
                }
            }
        }

        // Set upline addresses
        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        // Distribute the remaining amount among upline and downlines
        uint256 remainingAmount = packagePrice - 2 * 10**6;

        // Transfer USDT to upline1
        IERC20(usdtToken).transfer(upline1, remainingAmount / 2);

        distributeUSDT(referrerAddress, remainingAmount / 2, packageIndex);

        // Check if the maximum secondary downlines limit is reached
        if (
            secondLayerDownlines[packageIndex][upline[referrerAddress]]
                .length == packageInfo[packageIndex].maxSecondaryDownlines
        ) {
            // Find the upline of upline2
            address uplineOfUpline2 = upline[upline[referrerAddress]];

            // Check if uplineOfUpline2 exists and has less than 4 downlines
            if (
                uplineOfUpline2 != address(0) &&
                downlines[packageIndex][uplineOfUpline2].length <
                packageInfo[packageIndex].maxDirectDownlines
            ) {
                // Add upline2 to the direct downlines of uplineOfUpline2
                downlines[packageIndex][uplineOfUpline2].push(
                    upline[referrerAddress]
                );
                upline[upline[referrerAddress]] = uplineOfUpline2;
                secondLayerDownlines[packageIndex][upline[uplineOfUpline2]]
                    .push(upline[referrerAddress]);
            } else {
                // If uplineOfUpline2 already has 4 downlines, find its downline which has less than 4 downlines
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][uplineOfUpline2].length;
                    i++
                ) {
                    address downlineOfUpline2 = downlines[packageIndex][
                        uplineOfUpline2
                    ][i];
                    if (
                        downlines[packageIndex][downlineOfUpline2].length <
                        packageInfo[packageIndex].maxDirectDownlines
                    ) {
                        // Add upline2 to the direct downlines of downlineOfUpline2
                        downlines[packageIndex][downlineOfUpline2].push(
                            upline[referrerAddress]
                        );
                        upline[upline[referrerAddress]] = downlineOfUpline2;
                        secondLayerDownlines[packageIndex][
                            upline[downlineOfUpline2]
                        ].push(upline[referrerAddress]);
                        break;
                    }
                }
            }

            if (
                secondLayerDownlines[packageIndex][upline[referrerAddress]]
                    .length == packageInfo[packageIndex].maxSecondaryDownlines
            ) {
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    true
                );
                updateAndSetDistributionAddresses(
                    uplineOfUpline2,
                    packageIndex
                );
                // Distribute to upline3 and upline4 for 15
                IERC20(usdtToken).transfer(upline1, remainingAmount / 2);
                IERC20(usdtToken).transfer(upline2, remainingAmount / 2);
                emit PackagePurchased(
                    upline[referrerAddress],
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    address(0),
                    address(0),
                    address(0),
                    false,
                    true
                );
            }

            // Clear downlines and secondLayerDownlines for the upline and specific package
            clearDownlines(upline[referrerAddress]);
            clearSecondLayerDownlines(referrerAddress);
        }
        // Remove the user from the downlines of their previous upline
        userPackages[msg.sender] = packageIndex;
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

    function distributeUSDT(
        address referrerAddress,
        uint256 amountToDistribute,
        uint256 packageIndex
    ) internal {
        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            upline[referrerAddress]
        ];
        uint256 i = secondLayer.length;
        uint256 packagePrice = packageInfo[packageIndex].price;
        // Distribute USDT according to the conditions
        if (secondLayer.length <= 14) {
            if (i >= 0 && i <= 2) {
                // Distribute to RoyaltyContract for the first 3 downlines
                IERC20(usdtToken).transfer(RoyaltyContract, amountToDistribute);
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    true,
                    false
                );
            } else if (i >= 3 && i <= 13) {
                // Distribute to upline2 for downlines 4 to 13
                IERC20(usdtToken).transfer(upline2, amountToDistribute);
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false
                );
            } else if (i == 14) {
                uint256 halfAmount = amountToDistribute / 2;
                // Distribute to upline3 and upline4 for downlines 14
                IERC20(usdtToken).transfer(address(this), halfAmount);
                IERC20(usdtToken).transfer(address(this), halfAmount);
                emit PackagePurchased(
                    msg.sender,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    true
                );
            }
        }
    }

    function getSecondLayerDownlines(address user)
        external
        view
        returns (address[] memory)
    {
        return secondLayerDownlines[userPackages[user]][user];
    }

    // Function to clear downlines for the specified upline and package
    function clearDownlines(address uplineAddress) internal {
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
    function clearSecondLayerDownlines(address uplineAddress) internal {
        delete secondLayerDownlines[userPackages[upline[uplineAddress]]][
            upline[uplineAddress]
        ];

        address[] storage secondLayer = secondLayerDownlines[
            userPackages[upline[uplineAddress]]
        ][upline[uplineAddress]];
        for (uint256 i = 0; i < secondLayer.length; i++) {
            delete userPackages[secondLayer[i]];
        }
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
    }

    function ownerBuysAllPackages() external onlyOwner {
        // Iterate through all packages and purchase them for the owner
        for (uint256 i = 0; i < packageInfo.length; i++) {
            // Update user's package index
            userPackages[owner()] = i;
        }
    }
}
