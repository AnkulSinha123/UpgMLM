// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Registration.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";


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

contract Pro_Power_Global is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    mapping(address => uint256) public globalUserPackages;
    mapping(uint256 => mapping(uint256 => address)) public users;
    mapping(uint256 => mapping(address => address)) public structureUpline1;
    mapping(uint256 => mapping(address => address)) public structureUpline2;
    mapping(uint256 => uint256) public currentEmptyPos;
    uint256 public emptyPos = 0;
    uint256 public packageInd;
    address public User;

    struct PackageInfo {
        uint256 packagePrice;
        uint256 levelIncome;
    }

    PackageInfo[] public packageInfos;

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

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
        bool recycle11,
        bool recycle12,
        address structureUpline1,
        address structureUpline2
    );

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;

    IERC20 public usdtToken;
    address payable public RoyaltyContract;
    RegistrationInterface public registration;

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 50;
    uint256 private constant upline2_PERCENTAGE = 20;
    uint256 private constant upline3_PERCENTAGE = 10;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    receive() external payable {}

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        packageInfos.push(PackageInfo(0, 0));
        packageInfos.push(PackageInfo(5 * 10**18, 3 * 10**18));
        packageInfos.push(PackageInfo(10 * 10**18, 6 * 10**18));
        packageInfos.push(PackageInfo(15 * 10**18, 9 * 10**18));
        packageInfos.push(PackageInfo(25 * 10**18, 15 * 10**18));
        packageInfos.push(PackageInfo(50 * 10**18, 30 * 10**18));
        packageInfos.push(PackageInfo(100 * 10**18, 60 * 10**18));
        packageInfos.push(PackageInfo(200 * 10**18, 120 * 10**18));
        packageInfos.push(PackageInfo(400 * 10**18, 240 * 10**18));
        packageInfos.push(PackageInfo(800 * 10**18, 450 * 10**18));
        packageInfos.push(PackageInfo(1600 * 10**18, 900 * 10**18));
        packageInfos.push(PackageInfo(3000 * 10**18, 1600 * 10**18));
        packageInfos.push(PackageInfo(5000 * 10**18, 3000 * 10**18));

        upline1 = payable(owner());
        upline2 = payable(owner());
        upline3 = payable(owner());
        upline4 = payable(owner());
        upline5 = payable(owner());
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

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
            if (globalUserPackages[userUpline] >= packageIndex) {
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
                referrer != address(0) &&
                globalUserPackages[referrer] < packageIndex
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

    function distributeLevelUSDT(uint256 packageIndex) internal {
        uint256 usdtToDistribute = packageInfos[packageIndex].levelIncome;

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

    function isRecyclePos11(uint256 pos) internal pure returns (bool) {
        if (pos == 2 || pos == 3) {
            return false;
        } else if (pos == 11 || (pos - 11) % 9 == 0) {
            return true;
        }
        return false;
    }

    function isRecyclePos12(uint256 pos) internal pure returns (bool) {
        if (pos == 12 || (pos - 12) % 9 == 0) {
            return true;
        }
        return false;
    }

    function isRoyalty(uint256 pos) internal pure returns (bool) {
        if (pos == 4 || pos == 5) {
            return true;
        }
        if ((pos - 4) % 9 == 0 || (pos - 5) % 9 == 0) {
            return true;
        }
        return false;
    }

    function findUpline(uint256 pos) internal pure returns (uint256) {
        if (pos % 3 == 0) {
            return pos / 3 - 1;
        }
        return pos / 3;
    }

    function ownerBuysAllPackages() external onlyOwner {
        require(emptyPos == 0);
        // Iterate through all packages and purchase them for the owner
        for (uint256 i = 1; i < packageInfos.length; i++) {
            currentEmptyPos[i] = emptyPos;
            // Update user's package index
            globalUserPackages[owner()] = i;
            users[i][currentEmptyPos[i]] = owner();
            structureUpline1[i][owner()] = address(0);
            structureUpline2[i][owner()] = address(0);
            uint256 packagePrice = packageInfos[i].packagePrice;

            currentEmptyPos[i] += 1;

            emit PackagePurchased(
                owner(),
                i,
                packagePrice,
                upline1,
                upline2,
                upline3,
                upline4,
                upline5,
                false,
                false,
                false,
                address(0),
                address(0)
            );
        }
    }

    function globalPurchase(uint256 packageIndex) public {
        require(
            packageIndex > 0 && packageIndex < packageInfos.length,
            "Invalid package index"
        );
        uint256 currentPackageIndex = globalUserPackages[msg.sender];
        require(
            packageIndex == currentPackageIndex + 1,
            "Purchase packages sequentially"
        );
        address user = msg.sender;
        require(getUserInfo(user).isRegistered, "Not registered");
        require(
            users[packageIndex][currentEmptyPos[packageIndex]] == address(0),
            "Position is not empty"
        );

        address referrer = getUserInfo(user).referrer;

        uint256 packagePrice = packageInfos[packageIndex].packagePrice;
        uint256 remainingAmount = packageInfos[packageIndex].packagePrice -
            packageInfos[packageIndex].levelIncome;
        uint256 amountToDistribute = remainingAmount / 2;
        globalUserPackages[user] = packageIndex;
        packageInd = packageIndex;

        usdtToken.approve(address(this), packagePrice);
        usdtToken.transferFrom(user, address(this), packagePrice);

        users[packageIndex][currentEmptyPos[packageIndex]] = user;

        if (
            currentEmptyPos[packageIndex] == 1 ||
            currentEmptyPos[packageIndex] == 2 ||
            currentEmptyPos[packageIndex] == 3
        ) {
            structureUpline1[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);
            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );
            currentEmptyPos[packageIndex] += 1;

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
                owner(),
                address(0)
            );
            return;
        } else if (
            currentEmptyPos[packageIndex] == 4 ||
            currentEmptyPos[packageIndex] == 5
        ) {
            structureUpline1[packageIndex][user] = users[packageIndex][1];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);
            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(RoyaltyContract, amountToDistribute);
            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][1],
                users[packageInd][0]
            );
            return;
        } else if (currentEmptyPos[packageIndex] == 6) {
            structureUpline1[packageIndex][user] = users[packageIndex][1];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);
            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(
                structureUpline2[packageIndex][user],
                amountToDistribute
            );
            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][1],
                users[packageInd][0]
            );
            return;
        } else if (
            currentEmptyPos[packageIndex] == 7 ||
            currentEmptyPos[packageIndex] == 8 ||
            currentEmptyPos[packageIndex] == 9
        ) {
            structureUpline1[packageIndex][user] = users[packageIndex][2];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);
            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(
                structureUpline2[packageIndex][user],
                amountToDistribute
            );
            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][2],
                users[packageInd][0]
            );
            return;
        } else if (currentEmptyPos[packageIndex] == 10) {
            structureUpline1[packageIndex][user] = users[packageIndex][3];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);

            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(
                structureUpline2[packageIndex][user],
                amountToDistribute
            );
            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][3],
                users[packageInd][0]
            );
            return;
        } else if (currentEmptyPos[packageIndex] == 11) {
            structureUpline1[packageIndex][user] = users[packageIndex][3];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);

            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(address(this), amountToDistribute);
            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][3],
                users[packageInd][0]
            );
            return;
        } else {
            uint256 uplinePos = findUpline(currentEmptyPos[packageIndex]);

            structureUpline1[packageIndex][user] = users[packageIndex][
                uplinePos
            ];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distributeLevelUSDT(packageIndex);

            usdtToken.transfer(
                structureUpline1[packageIndex][user],
                amountToDistribute
            );

            uint256 pos = currentEmptyPos[packageIndex];
            if (isRecyclePos11(pos)) {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];

                usdtToken.transfer(address(this), amountToDistribute);

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
                    structureUpline1[packageInd][msg.sender],
                    structureUpline2[packageInd][msg.sender]
                );
            } else if (isRecyclePos12(pos)) {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];

                address structureUplineTwo = structureUpline2[packageIndex][
                    user
                ];

                uint256 uplinePosRecycle = findUpline(
                    currentEmptyPos[packageIndex]
                );
                users[packageIndex][
                    currentEmptyPos[packageIndex]
                ] = structureUplineTwo;

                currentEmptyPos[packageIndex] += 1;

                structureUpline1[packageIndex][structureUplineTwo] = users[
                    packageIndex
                ][uplinePosRecycle];
                structureUpline2[packageIndex][
                    structureUplineTwo
                ] = structureUpline1[packageIndex][
                    structureUpline1[packageIndex][structureUplineTwo]
                ];

                usdtToken.transfer(
                    structureUpline1[packageIndex][structureUplineTwo],
                    amountToDistribute
                );
                usdtToken.transfer(RoyaltyContract, amountToDistribute);

                address newUpline2 = structureUplineTwo;

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
                    structureUpline1[packageInd][msg.sender],
                    structureUpline2[packageInd][msg.sender]
                );

                emit PackagePurchased(
                    structureUplineTwo,
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
                    structureUpline1[packageInd][newUpline2],
                    structureUpline2[packageInd][newUpline2]
                );
            } else if (isRoyalty(pos)) {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];
                usdtToken.transfer(RoyaltyContract, amountToDistribute);

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
                    structureUpline1[packageInd][msg.sender],
                    structureUpline2[packageInd][msg.sender]
                );
            } else {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];
                usdtToken.transfer(
                    structureUpline2[packageIndex][user],
                    amountToDistribute
                );

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
                    structureUpline1[packageInd][msg.sender],
                    structureUpline2[packageInd][msg.sender]
                );
            }
        }
    }

    function provideGlobalPurchase(uint256 packageIndex, address user)
        internal
    {
        require(
            packageIndex > 0 && packageIndex < packageInfos.length,
            "Invalid package index"
        );

        User = user;
        uint256 currentPackageIndex = globalUserPackages[user];
        require(
            packageIndex == currentPackageIndex + 1,
            "Purchase packages sequentially"
        );

        require(getUserInfo(user).isRegistered, "Not registered");
        require(
            users[packageIndex][currentEmptyPos[packageIndex]] == address(0),
            "Position is not empty"
        );

        address referrer = getUserInfo(user).referrer;

        uint256 packagePrice = packageInfos[packageIndex].packagePrice;

        globalUserPackages[user] = packageIndex;
        packageInd = packageIndex;

        users[packageIndex][currentEmptyPos[packageIndex]] = user;

        if (
            currentEmptyPos[packageIndex] == 1 ||
            currentEmptyPos[packageIndex] == 2 ||
            currentEmptyPos[packageIndex] == 3
        ) {
            structureUpline1[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            currentEmptyPos[packageIndex] += 1;

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
                owner(),
                address(0)
            );
            return;
        } else if (
            currentEmptyPos[packageIndex] == 4 ||
            currentEmptyPos[packageIndex] == 5
        ) {
            structureUpline1[packageIndex][user] = users[packageIndex][1];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);

            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][1],
                users[packageInd][0]
            );
            return;
        } else if (currentEmptyPos[packageIndex] == 6) {
            structureUpline1[packageIndex][user] = users[packageIndex][1];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);

            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][1],
                users[packageInd][0]
            );
            return;
        } else if (
            currentEmptyPos[packageIndex] == 7 ||
            currentEmptyPos[packageIndex] == 8 ||
            currentEmptyPos[packageIndex] == 9
        ) {
            structureUpline1[packageIndex][user] = users[packageIndex][2];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);

            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][2],
                users[packageInd][0]
            );
            return;
        } else if (currentEmptyPos[packageIndex] == 10) {
            structureUpline1[packageIndex][user] = users[packageIndex][3];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);

            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][3],
                users[packageInd][0]
            );
            return;
        } else if (currentEmptyPos[packageIndex] == 11) {
            structureUpline1[packageIndex][user] = users[packageIndex][3];
            structureUpline2[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);

            currentEmptyPos[packageIndex] += 1;

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
                users[packageInd][3],
                users[packageInd][0]
            );
            return;
        } else {
            uint256 uplinePos = findUpline(currentEmptyPos[packageIndex]);
            structureUpline1[packageIndex][user] = users[packageIndex][
                uplinePos
            ];
            updateAndSetDistributionAddresses(referrer, packageIndex);

            uint256 pos = currentEmptyPos[packageIndex];
            if (isRecyclePos11(pos)) {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];

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
                    structureUpline1[packageInd][User],
                    structureUpline2[packageInd][User]
                );
            } else if (isRecyclePos12(pos)) {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];

                address structureUplineTwo = structureUpline2[packageIndex][
                    user
                ];

                uint256 uplinePosRecycle = findUpline(
                    currentEmptyPos[packageIndex]
                );
                users[packageIndex][
                    currentEmptyPos[packageIndex]
                ] = structureUplineTwo;

                currentEmptyPos[packageIndex] += 1;

                structureUpline1[packageIndex][structureUplineTwo] = users[
                    packageIndex
                ][uplinePosRecycle];
                structureUpline2[packageIndex][
                    structureUplineTwo
                ] = structureUpline1[packageIndex][
                    structureUpline1[packageIndex][structureUplineTwo]
                ];

                address newUpline2 = structureUplineTwo;

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
                    structureUpline1[packageInd][User],
                    structureUpline2[packageInd][User]
                );

                emit PackagePurchased(
                    structureUplineTwo,
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
                    structureUpline1[packageInd][newUpline2],
                    structureUpline2[packageInd][newUpline2]
                );
            } else if (isRoyalty(pos)) {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];

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
                    structureUpline1[packageInd][User],
                    structureUpline2[packageInd][User]
                );
            } else {
                currentEmptyPos[packageIndex] += 1;
                structureUpline2[packageIndex][user] = structureUpline1[
                    packageIndex
                ][users[packageIndex][uplinePos]];

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
                    structureUpline1[packageInd][User],
                    structureUpline2[packageInd][User]
                );
            }
        }
    }

    function provideGlobalPackagesBulk(
        uint256 endPackageIndex,
        address[] calldata users
    ) external onlyOwner {
        uint256 startPackageIndex;
        for (uint256 j = 0; j < users.length; j++) {
            startPackageIndex = globalUserPackages[users[j]] + 1;
            require(
                startPackageIndex > 0 &&
                    endPackageIndex < packageInfos.length &&
                    startPackageIndex <= endPackageIndex,
                "Invalid package indexes"
            );

            for (uint256 i = startPackageIndex; i <= endPackageIndex; i++) {
                provideGlobalPurchase(i, users[j]);
            }
        }
    }

    function withdrawGlobalUSDT(uint256 amount) public onlyOwner {
        usdtToken.transfer(owner(), amount);
    }

    function getGlobalUSDTBalance() external view onlyOwner returns (uint256) {
        return usdtToken.balanceOf(address(this));
    }
}
