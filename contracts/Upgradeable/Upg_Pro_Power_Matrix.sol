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
    mapping(uint256 => mapping(address => address[]))
        public secondLayerDownlines;

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;
    address payable public structureUpline1;
    address payable public structureUpline2;

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
        bool recycle15,
        bool recycle16,
        address structureUpline1,
        address structureUpline2
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

        packageInfo.push(Package(0, 0, 0));
        packageInfo.push(Package(5 * 10**18, 4, 16));
        packageInfo.push(Package(8 * 10**18, 4, 16));
        packageInfo.push(Package(14 * 10**18, 4, 16));
        packageInfo.push(Package(26 * 10**18, 4, 16));
        packageInfo.push(Package(50 * 10**18, 4, 16));
        packageInfo.push(Package(98 * 10**18, 4, 16));
        packageInfo.push(Package(194 * 10**18, 4, 16));
        packageInfo.push(Package(386 * 10**18, 4, 16));
        packageInfo.push(Package(770 * 10**18, 4, 16));
        packageInfo.push(Package(1538 * 10**18, 4, 16));
        packageInfo.push(Package(3074 * 10**18, 4, 16));
        packageInfo.push(Package(6146 * 10**18, 4, 16));

        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());
        structureUpline1 = payable(owner());
        structureUpline2 = payable(owner());
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

        uint256 qualifiedUplinesFound = 0;

        // Iterate through uplines until 5 qualified uplines are found or until the user's package index is greater than or equal to the upline's package index
        while (userUpline != address(0) && qualifiedUplinesFound < 5) {
            if (userPackages[userUpline] >= packageIndex) {
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
            }

            // Move up to the next referrer
            address referrer = getUserInfo(userUpline).referrer;
            while (
                referrer != address(0) && userPackages[referrer] < packageIndex
            ) {
                referrer = getUserInfo(referrer).referrer;
            }

            if (referrer == address(0)) {
                break; // Break the loop if no referrer with a matching or higher package index is found
            }

            userUpline = referrer;
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
        require(
            packageIndex > 0 && packageIndex < packageInfo.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Must purchase packages sequentially"
        );

        uint256 packagePrice = packageInfo[packageIndex].price;

        IERC20(usdtToken).approve(address(this), packagePrice);

        // Transfer USDT from the user to the contract
        IERC20(usdtToken).transferFrom(msg.sender, address(this), packagePrice);

        // Check if the user is registered
        require(getUserInfo(msg.sender).isRegistered, "User is not registered");

        address referrerAddress = getUserInfo(msg.sender).referrer;
        upline[msg.sender] = referrerAddress;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        uint256 remainingAmount = packagePrice - 2 * 10**18;

        // Check if the specified upline already has 4 downlines
        if (
            downlines[packageIndex][upline1].length <
            packageInfo[packageIndex].maxDirectDownlines
        ) {
            downlines[packageIndex][upline1].push(msg.sender);
            upline[msg.sender] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[structureUpline1]);

            if (upline1 != owner()) {
                secondLayerDownlines[packageIndex][structureUpline2].push(
                    msg.sender
                );
            }
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][upline1][i];
                if (
                    downlines[packageIndex][downlineAddress].length <
                    packageInfo[packageIndex].maxDirectDownlines
                ) {
                    downlines[packageIndex][downlineAddress].push(msg.sender);
                    upline[msg.sender] = downlineAddress;
                    structureUpline1 = payable(downlineAddress);
                    structureUpline2 = payable(upline[downlineAddress]);

                    if (downlineAddress != owner()) {
                        secondLayerDownlines[packageIndex][structureUpline2]
                            .push(msg.sender);
                    }
                    break;
                }
            }
        }
        IERC20(usdtToken).transfer(structureUpline1, remainingAmount / 2);
        distributeUSDT(structureUpline2, remainingAmount / 2, packageIndex);

        // Check if the maximum secondary downlines limit is reached
        if (
            secondLayerDownlines[packageIndex][structureUpline2].length ==
            packageInfo[packageIndex].maxSecondaryDownlines
        ) {
            address UplineOfStructure2 = upline[structureUpline2];
            address uplineToUplineOfStructure2 = upline[
                upline[structureUpline2]
            ];

            if (structureUpline2 == owner()) {
                downlines[packageIndex][owner()] = new address[](0);
                secondLayerDownlines[packageIndex][owner()] = new address[](0);
                emit PackagePurchased(
                    owner(),
                    packageIndex,
                    packagePrice,
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    false,
                    false,
                    true,
                    address(0),
                    address(0)
                );
            }

            if (
                UplineOfStructure2 != address(0) &&
                downlines[packageIndex][UplineOfStructure2].length <
                packageInfo[packageIndex].maxDirectDownlines
            ) {
                // Add structureUpline2 to the direct downlines of uplineOfUpline2
                downlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner()) {
                    secondLayerDownlines[packageIndex][
                        uplineToUplineOfStructure2
                    ].push(structureUpline2);
                }
                IERC20(usdtToken).transfer(
                    UplineOfStructure2,
                    remainingAmount / 2
                );
                IERC20(usdtToken).transfer(
                    uplineToUplineOfStructure2,
                    remainingAmount / 2
                );

                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(
                    structureUpline2,
                    uplineToUplineOfStructure2,
                    packageIndex
                );

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
                    false,
                    true,
                    structureUpline1,
                    structureUpline2
                );

                emit PackagePurchased(
                    structureUpline2,
                    packageIndex,
                    packagePrice,
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    false,
                    false,
                    true,
                    UplineOfStructure2,
                    uplineToUplineOfStructure2
                );
            } else {
                // If upline3 already has 4 downlines, find its downline which has less than 4 downlines
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = downlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .length <
                        packageInfo[packageIndex].maxDirectDownlines
                    ) {
                        // Add structureUpline2 to the direct downlines of downlineOfUplineOfStructure2
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .push(structureUpline2);
                        upline[structureUpline2] = downlineOfUplineOfStructure2;

                        if (downlineOfUplineOfStructure2 != owner()) {
                            secondLayerDownlines[packageIndex][
                                UplineOfStructure2
                            ].push(structureUpline2);
                        }
                        // Distribute to upline3 and upline4 for 15
                        IERC20(usdtToken).transfer(
                            downlineOfUplineOfStructure2,
                            remainingAmount / 2
                        );
                        IERC20(usdtToken).transfer(
                            UplineOfStructure2,
                            remainingAmount / 2
                        );
                        clearDownlines(
                            structureUpline2,
                            downlineOfUplineOfStructure2,
                            packageIndex
                        );
                        clearSecondLayerDownlines(
                            structureUpline2,
                            UplineOfStructure2,
                            packageIndex
                        );
                        break;
                    }
                }
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
                    false,
                    true,
                    structureUpline1,
                    structureUpline2
                );

                emit PackagePurchased(
                    structureUpline2,
                    packageIndex,
                    packagePrice,
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    false,
                    false,
                    true,
                    upline[structureUpline2],
                    UplineOfStructure2
                );
            }
        }
        // Remove the user from the downlines of their previous upline
        userPackages[msg.sender] = packageIndex;
    }

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * 10**18; // 2 USDT

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
        address StructureUpline2,
        uint256 amountToDistribute,
        uint256 packageIndex
    ) internal {
        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            StructureUpline2
        ];
        uint256 i = secondLayer.length;
        uint256 packagePrice = packageInfo[packageIndex].price;
        // Distribute USDT according to the conditions
        if (secondLayer.length <= 15) {
            if (i == 0) {
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
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 1 && i <= 3) {
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
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 4 && i <= 14) {
                // Distribute to upline2 for downlines 4 to 13
                IERC20(usdtToken).transfer(
                    structureUpline2,
                    amountToDistribute
                );
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
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 15) {
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
                    true,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            }
        }
    }

    // Function to clear secondLayerDownlines for the specified upline and package
    function clearSecondLayerDownlines(
        address userAddress,
        uint256 packageIndex
    ) internal {
        secondLayerDownlines[packageIndex][userAddress] = new address[](0);
    }

    function ownerBuysAllPackages() external onlyOwner {
        // Iterate through all packages and purchase them for the owner
        for (uint256 i = 1; i < packageInfo.length; i++) {
            // Update user's package index
            userPackages[owner()] = i;
            uint256 packagePrice = packageInfo[i].price;

            emit PackagePurchased(
                owner(),
                i,
                packagePrice,
                address(0),
                address(0),
                address(0),
                address(0),
                address(0),
                false,
                false,
                false,
                address(0),
                address(0)
            );
        }
    }

    function providePackage(uint256 packageIndex, address user)
        internal
        onlyOwner
    {
        require(
            packageIndex > 0 && packageIndex < packageInfo.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = userPackages[user];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Must provide packages sequentially"
        );

        // Check if the user is registered
        require(getUserInfo(user).isRegistered, "User is not registered");

        address referrerAddress = getUserInfo(user).referrer;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        upline[user] = referrerAddress;

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Check if the specified upline already has 4 downlines
        if (
            downlines[packageIndex][upline1].length <
            packageInfo[packageIndex].maxDirectDownlines
        ) {
            downlines[packageIndex][upline1].push(user);
            upline[user] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[structureUpline1]);

            if (upline1 != owner()) {
                secondLayerDownlines[packageIndex][structureUpline2].push(user);
            }
        } else {
            for (
                uint256 i = 0;
                i < downlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = downlines[packageIndex][upline1][i];
                if (
                    downlines[packageIndex][downlineAddress].length <
                    packageInfo[packageIndex].maxDirectDownlines
                ) {
                    downlines[packageIndex][downlineAddress].push(user);
                    upline[user] = downlineAddress;
                    structureUpline1 = payable(downlineAddress);
                    structureUpline2 = payable(upline[downlineAddress]);
                    if (structureUpline1 != owner()) {
                        secondLayerDownlines[packageIndex][structureUpline2]
                            .push(user);
                    }
                    break;
                }
            }
        }

        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            structureUpline2
        ];
        uint256 i = secondLayer.length;
        uint256 packagePrice = packageInfo[packageIndex].price;

        if (secondLayer.length <= 16) {
            if (i == 0) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 1 && i <= 3) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    true,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i >= 4 && i <= 14) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 15) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    true,
                    false,
                    structureUpline1,
                    structureUpline2
                );
            } else if (i == 16) {
                emit PackagePurchased(
                    user,
                    packageIndex,
                    packagePrice,
                    upline1,
                    upline2,
                    upline3,
                    upline4,
                    upline5,
                    false,
                    false,
                    true,
                    structureUpline1,
                    structureUpline2
                );
            }
        }

        // Check if the maximum secondary downlines limit is reached
        if (secondLayer.length == 16) {
            address UplineOfStructure2 = upline[structureUpline2];
            address uplineToUplineOfStructure2 = upline[
                upline[structureUpline2]
            ];

            if (structureUpline2 == owner()) {
                downlines[packageIndex][owner()] = new address[](0);
                secondLayerDownlines[packageIndex][owner()] = new address[](0);
                emit PackagePurchased(
                    owner(),
                    packageIndex,
                    packagePrice,
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    false,
                    false,
                    true,
                    address(0),
                    address(0)
                );
            }

            if (
                UplineOfStructure2 != address(0) &&
                downlines[packageIndex][UplineOfStructure2].length <
                packageInfo[packageIndex].maxDirectDownlines
            ) {
                emit PackagePurchased(
                    structureUpline2,
                    packageIndex,
                    packagePrice,
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    false,
                    false,
                    true,
                    UplineOfStructure2,
                    uplineToUplineOfStructure2
                );
                // Add user to the direct downlines of uplineOfUpline2
                downlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner()) {
                    secondLayerDownlines[packageIndex][
                        uplineToUplineOfStructure2
                    ].push(structureUpline2);
                }

                clearDownlines(
                    structureUpline2,
                    UplineOfStructure2,
                    packageIndex
                );
                clearSecondLayerDownlines(
                    structureUpline2,
                    uplineToUplineOfStructure2,
                    packageIndex
                );
            } else {
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = downlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .length <
                        packageInfo[packageIndex].maxDirectDownlines
                    ) {
                        // Add user to the direct downlines of downlineOfUpline2
                        downlines[packageIndex][downlineOfUplineOfStructure2]
                            .push(structureUpline2);
                        upline[structureUpline2] = downlineOfUplineOfStructure2;
                        if (downlineOfUplineOfStructure2 != owner()) {
                            secondLayerDownlines[packageIndex][
                                UplineOfStructure2
                            ].push(structureUpline2);
                        }
                        clearDownlines(
                            structureUpline2,
                            downlineOfUplineOfStructure2,
                            packageIndex
                        );
                        clearSecondLayerDownlines(
                            structureUpline2,
                            UplineOfStructure2,
                            packageIndex
                        );
                        break;
                    }
                }
                emit PackagePurchased(
                    structureUpline2,
                    packageIndex,
                    packagePrice,
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    address(0),
                    false,
                    false,
                    true,
                    upline[structureUpline2],
                    UplineOfStructure2
                );
            }
        }
        // Remove the user from the downlines of their previous upline
        userPackages[user] = packageIndex;
    }

    function providePackagesBulk(uint256 endPackageIndex, address user)
        external
        onlyOwner
    {
        uint256 startPackageIndex = userPackages[user] + 1;
        require(
            startPackageIndex > 0 &&
                endPackageIndex < packageInfo.length &&
                startPackageIndex <= endPackageIndex,
            "Invalid package indexes"
        );

        for (uint256 i = startPackageIndex; i <= endPackageIndex; i++) {
            providePackage(i, user);
        }
    }

    function clearDownlines(
        address uplineToRecycle,
        address uplineOfUpline2,
        uint256 packageIndex
    ) internal {
        address[] storage downlineAddresses = downlines[packageIndex][
            uplineOfUpline2
        ];

        // Find the index of upline2 in the downlineAddresses array
        uint256 indexToDelete;
        for (uint256 i = 0; i < downlineAddresses.length; i++) {
            if (downlineAddresses[i] == uplineToRecycle) {
                indexToDelete = i;
                break;
            }
        }
        // If upline2 was found, "delete" it by setting the address to 0
        if (indexToDelete < downlineAddresses.length) {
            downlineAddresses[indexToDelete] = address(0);
        }
        downlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function clearSecondLayerDownlines(
        address uplineToRecycle,
        address secUplineOfUpline2,
        uint256 packageIndex
    ) internal {
        address[] storage secdownlineAddresses = secondLayerDownlines[
            packageIndex
        ][secUplineOfUpline2];

        // Find the index of upline2 in the downlineAddresses array
        uint256 indexToDelete;
        for (uint256 i = 0; i < secdownlineAddresses.length; i++) {
            if (secdownlineAddresses[i] == uplineToRecycle) {
                indexToDelete = i;
                break;
            }
        }
        // If upline2 was found, "delete" it by setting the address to 0
        if (indexToDelete < secdownlineAddresses.length) {
            secdownlineAddresses[indexToDelete] = address(0);
        }
        secondLayerDownlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function withdrawUSDT(uint256 amount) public onlyOwner {
        IERC20(usdtToken).transfer(owner(), amount);
    }
}
