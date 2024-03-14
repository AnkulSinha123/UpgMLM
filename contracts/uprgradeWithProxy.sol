// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
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

contract Pro_Power_Matrix is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        packagePrices.push(0);
        packagePrices.push(5 * 10**18);
        packagePrices.push(8 * 10**18);
        packagePrices.push(14 * 10**18);
        packagePrices.push(26 * 10**18);
        packagePrices.push(50 * 10**18);
        packagePrices.push(98 * 10**18);
        packagePrices.push(194 * 10**18);
        packagePrices.push(386 * 10**18);
        packagePrices.push(770 * 10**18);
        packagePrices.push(1538 * 10**18);
        packagePrices.push(3074 * 10**18);
        packagePrices.push(6146 * 10**18);

        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());
        structureUpline1 = payable(owner());
        structureUpline2 = payable(owner());
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

    uint256[] public packagePrices;

    mapping(address => uint256) public userPackages;
    mapping(uint256 => mapping(address => address[])) public downlines;
    mapping(uint256 => mapping(address => address[]))
        public secondLayerDownlines;
    mapping(uint256 => mapping(address => address)) public upline;

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;
    address payable public structureUpline1;
    address payable public structureUpline2;
    address payable public uplineToUplineOFStructureUpline2;

    IERC20 public usdtToken;
    address payable public RoyaltyContract;
    RegistrationInterface public registration;

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

    receive() external payable {}

    function setRegistration(address _registrationAddress) external onlyOwner {
        registration = RegistrationInterface(_registrationAddress);
    }

    function setRoyalty(address _royalty) external onlyOwner {
        RoyaltyContract = payable(_royalty);
    }

    function setUSDT(address _usdtToken) external onlyOwner {
        usdtToken = IERC20(_usdtToken);
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

        // If upline1, upline2, upline3, upline4, or upline5 are not set, set them to the contract owner()
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
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = userPackages[msg.sender];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Purchase packages sequentially"
        );

        uint256 packagePrice = packagePrices[packageIndex];

        usdtToken.approve(address(this), packagePrice);

        // Transfer USDT from the user to the contract
        usdtToken.transferFrom(msg.sender, address(this), packagePrice);

        // Check if the user is registered
        require(getUserInfo(msg.sender).isRegistered, "Not registered");

        address referrerAddress = getUserInfo(msg.sender).referrer;
        upline[packageIndex][msg.sender] = referrerAddress;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        uint256 remainingAmount = packagePrice - 2 * 10**18;

        // Check if the specified upline already has 4 downlines
        if (downlines[packageIndex][upline1].length < 4) {
            downlines[packageIndex][upline1].push(msg.sender);
            upline[packageIndex][msg.sender] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[packageIndex][structureUpline1]);

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
                if (downlineAddress != address(0)) {
                    if (downlines[packageIndex][downlineAddress].length < 4) {
                        downlines[packageIndex][downlineAddress].push(
                            msg.sender
                        );
                        upline[packageIndex][msg.sender] = downlineAddress;
                        structureUpline1 = payable(downlineAddress);
                        structureUpline2 = payable(
                            upline[packageIndex][downlineAddress]
                        );

                        if (downlineAddress != owner()) {
                            secondLayerDownlines[packageIndex][structureUpline2]
                                .push(msg.sender);
                        }
                        break;
                    }
                }
            }
        }
        usdtToken.transfer(structureUpline1, remainingAmount / 2);
        distributeUSDT(structureUpline2, remainingAmount / 2, packageIndex);
        if (secondLayerDownlines[packageIndex][structureUpline2].length == 16) {
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
        }
        if (secondLayerDownlines[packageIndex][structureUpline2].length == 16) {
            recycleProcess(packageIndex, remainingAmount, structureUpline2);
        }

        // Remove the user from the downlines of their previous upline
        userPackages[msg.sender] = packageIndex;
    }

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * 10**18; // 2 USDT

        // Transfer USDT to levels
        usdtToken.transfer(
            upline1,
            (usdtToDistribute * upline1_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline2,
            (usdtToDistribute * upline2_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline3,
            (usdtToDistribute * upline3_PERCENTAGE) / 100
        );
        usdtToken.transfer(
            upline4,
            (usdtToDistribute * upline4_PERCENTAGE) / 100
        );
        usdtToken.transfer(
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
        uint256 packagePrice = packagePrices[packageIndex];
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
                usdtToken.transfer(RoyaltyContract, amountToDistribute);
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
                usdtToken.transfer(structureUpline2, amountToDistribute);
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
                // Distribute to upline3 and upline4 for downlines 14
                usdtToken.transfer(address(this), amountToDistribute);

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

    function ownerBuysAllPackages() external onlyOwner {
        // Iterate through all packages and purchase them for the owner
        for (uint256 i = 1; i < packagePrices.length; i++) {
            // Update user's package index
            userPackages[owner()] = i;
            uint256 packagePrice = packagePrices[i];

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
            packageIndex > 0 && packageIndex < packagePrices.length,
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

        upline[packageIndex][user] = referrerAddress;

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Check if the specified upline already has 4 downlines
        if (downlines[packageIndex][upline1].length < 4) {
            downlines[packageIndex][upline1].push(user);
            upline[packageIndex][user] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(upline[packageIndex][structureUpline1]);

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
                if (downlineAddress != address(0)) {
                    if (downlines[packageIndex][downlineAddress].length < 4) {
                        downlines[packageIndex][downlineAddress].push(user);
                        upline[packageIndex][user] = downlineAddress;
                        structureUpline1 = payable(downlineAddress);
                        structureUpline2 = payable(
                            upline[packageIndex][downlineAddress]
                        );
                        if (structureUpline1 != owner()) {
                            secondLayerDownlines[packageIndex][structureUpline2]
                                .push(user);
                        }
                        break;
                    }
                }
            }
        }

        address[] storage secondLayer = secondLayerDownlines[packageIndex][
            structureUpline2
        ];
        uint256 i = secondLayer.length;
        uint256 packagePrice = packagePrices[packageIndex];

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
        if (secondLayer.length == 16) {
            recycleProvidePackage(packageIndex, structureUpline2);
        }
        userPackages[user] = packageIndex;
    }

    function providePackagesBulk(
        uint256 endPackageIndex,
        address[] calldata users
    ) external onlyOwner {
        uint256 startPackageIndex;
        for (uint256 j = 0; j < users.length; j++) {
            startPackageIndex = userPackages[users[j]] + 1;
            require(
                startPackageIndex > 0 &&
                    endPackageIndex < packagePrices.length &&
                    startPackageIndex <= endPackageIndex,
                "Invalid package indexes"
            );

            for (uint256 i = startPackageIndex; i <= endPackageIndex; i++) {
                providePackage(i, users[j]);
            }
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
        usdtToken.transfer(owner(), amount);
    }

    function recycleProcess(
        uint256 packageIndex,
        uint256 remaining,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = upline[packageIndex][structureUpline2];
        address uplineToUplineOfStructure2 = upline[packageIndex][
            upline[packageIndex][structureUpline2]
        ];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (structureUpline2 == owner())
        ) {
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
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (UplineOfStructure2 != address(0))
        ) {
            if (downlines[packageIndex][UplineOfStructure2].length < 4) {
                downlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner()) {
                    secondLayerDownlines[packageIndex][
                        uplineToUplineOfStructure2
                    ].push(structureUpline2);
                }
                usdtToken.transfer(UplineOfStructure2, remaining / 2);

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

                uint256 secondaryLine = secondLayerDownlines[packageIndex][
                    uplineToUplineOfStructure2
                ].length;

                if (secondaryLine == 16) {
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
                }

                if (secondaryLine >= 1 && secondaryLine <= 3) {
                    usdtToken.transfer(RoyaltyContract, remaining / 2);

                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        true,
                        false,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine >= 4 && secondaryLine <= 14) {
                    usdtToken.transfer(
                        uplineToUplineOfStructure2,
                        remaining / 2
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
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine == 15) {
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
                        true,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine == 16) {
                    recycleProcess(
                        packageIndex,
                        remaining,
                        uplineToUplineOfStructure2
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = downlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (downlineOfUplineOfStructure2 != address(0)) {
                        if (
                            downlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].length < 4
                        ) {
                            downlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].push(structureUpline2);
                            upline[packageIndex][
                                structureUpline2
                            ] = downlineOfUplineOfStructure2;
                            uplineToUplineOFStructureUpline2 = payable(
                                upline[packageIndex][
                                    downlineOfUplineOfStructure2
                                ]
                            );

                            if (downlineOfUplineOfStructure2 != owner()) {
                                secondLayerDownlines[packageIndex][
                                    UplineOfStructure2
                                ].push(structureUpline2);
                            }
                            usdtToken.transfer(
                                downlineOfUplineOfStructure2,
                                remaining / 2
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

                            uint256 secondaryLine = secondLayerDownlines[
                                packageIndex
                            ][UplineOfStructure2].length;

                            if (secondaryLine == 16) {
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
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            }

                            if (secondaryLine >= 1 && secondaryLine <= 3) {
                                emit PackagePurchased(
                                    structureUpline2,
                                    packageIndex,
                                    packagePrice,
                                    address(0),
                                    address(0),
                                    address(0),
                                    address(0),
                                    address(0),
                                    true,
                                    false,
                                    false,
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            } else if (
                                secondaryLine >= 4 && secondaryLine <= 14
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
                                    false,
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            } else if (secondaryLine == 15) {
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
                                    true,
                                    false,
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            } else if (secondaryLine == 16) {
                                recycleProcess(
                                    packageIndex,
                                    remaining,
                                    uplineToUplineOFStructureUpline2
                                );
                            }
                            break;
                        }
                    }
                }
            }
        }
    }

    function recycleProvidePackage(
        uint256 packageIndex,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = upline[packageIndex][structureUpline2];
        address uplineToUplineOfStructure2 = upline[packageIndex][
            upline[packageIndex][structureUpline2]
        ];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (structureUpline2 == owner())
        ) {
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
            (secondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (UplineOfStructure2 != address(0))
        ) {
            if (downlines[packageIndex][UplineOfStructure2].length < 4) {
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

                uint256 secondaryLine = secondLayerDownlines[packageIndex][
                    uplineToUplineOfStructure2
                ].length;

                if (secondaryLine == 16) {
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
                }

                if (secondaryLine >= 1 && secondaryLine <= 3) {
                    emit PackagePurchased(
                        structureUpline2,
                        packageIndex,
                        packagePrice,
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        address(0),
                        true,
                        false,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine >= 4 && secondaryLine <= 14) {
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
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine == 15) {
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
                        true,
                        false,
                        UplineOfStructure2,
                        uplineToUplineOfStructure2
                    );
                } else if (secondaryLine == 16) {
                    recycleProvidePackage(
                        packageIndex,
                        uplineToUplineOfStructure2
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < downlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = downlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (downlineOfUplineOfStructure2 != address(0)) {
                        if (
                            downlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].length < 4
                        ) {
                            downlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].push(structureUpline2);
                            upline[packageIndex][
                                structureUpline2
                            ] = downlineOfUplineOfStructure2;
                            uplineToUplineOFStructureUpline2 = payable(
                                upline[packageIndex][
                                    downlineOfUplineOfStructure2
                                ]
                            );

                            if (downlineOfUplineOfStructure2 != owner()) {
                                secondLayerDownlines[packageIndex][
                                    UplineOfStructure2
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

                            uint256 secondaryLine = secondLayerDownlines[
                                packageIndex
                            ][UplineOfStructure2].length;

                            if (secondaryLine == 16) {
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
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            }

                            if (secondaryLine >= 1 && secondaryLine <= 3) {
                                emit PackagePurchased(
                                    structureUpline2,
                                    packageIndex,
                                    packagePrice,
                                    address(0),
                                    address(0),
                                    address(0),
                                    address(0),
                                    address(0),
                                    true,
                                    false,
                                    false,
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            } else if (
                                secondaryLine >= 4 && secondaryLine <= 14
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
                                    false,
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            } else if (secondaryLine == 15) {
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
                                    true,
                                    false,
                                    downlineOfUplineOfStructure2,
                                    uplineToUplineOFStructureUpline2
                                );
                            } else if (secondaryLine == 16) {
                                recycleProvidePackage(
                                    packageIndex,
                                    uplineToUplineOFStructureUpline2
                                );
                            }

                            break;
                        }
                    }
                }
            }
        }
    }

    function setStructureUpline1(
        address user,
        address _structure1Upline,
        uint256 packageIndex
    ) external onlyOwner {
        upline[packageIndex][user] = payable(_structure1Upline);
    }

    function removeAddressFromSecLine(
        uint256 index,
        uint256 packageIndex,
        address user
    ) external onlyOwner {
        require(
            index < secondLayerDownlines[packageIndex][user].length,
            "Index out of bounds"
        );

        // Shift addresses back to fill the gap
        for (
            uint256 i = index;
            i < secondLayerDownlines[packageIndex][user].length - 1;
            i++
        ) {
            secondLayerDownlines[packageIndex][user][i] = secondLayerDownlines[
                packageIndex
            ][user][i + 1];
        }

        // Remove the last address
        secondLayerDownlines[packageIndex][user].pop();
    }

    function addAddressInSecLine(
        uint256 index,
        uint256 packageIndex,
        address user,
        address newAddress
    ) external onlyOwner {
        require(
            index <= secondLayerDownlines[packageIndex][user].length,
            "Index out of bounds"
        );

        // Shift addresses forward to make space for the new address
        secondLayerDownlines[packageIndex][user].push(); // Add a new element at the end
        for (
            uint256 i = secondLayerDownlines[packageIndex][user].length - 1;
            i > index;
            i--
        ) {
            secondLayerDownlines[packageIndex][user][i] = secondLayerDownlines[
                packageIndex
            ][user][i - 1];
        }

        // Add the new address at the specified index
        secondLayerDownlines[packageIndex][user][index] = newAddress;
    }

    function clearDownlinesByOwner(address user, uint256 packageIndex)
        public
        onlyOwner
    {
        downlines[packageIndex][user] = new address[](0);
    }

    function clearSecondaryDownlinesByOwner(address user, uint256 packageIndex)
        public
        onlyOwner
    {
        secondLayerDownlines[packageIndex][user] = new address[](0);
    }

    function setPackage(address payable user, uint256 _setPackage)
        external
        onlyOwner
    {
        userPackages[user] = _setPackage;
    }
}
