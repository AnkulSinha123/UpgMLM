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

contract Pro_Power_Global is Initializable, OwnableUpgradeable {
    uint256[] public packagePrices;
    mapping(address => uint256) public userPackages;
    mapping(uint256 => mapping(uint256 => address)) public users;
    mapping(uint256 => mapping(address => address)) public uplineOne;
    mapping(uint256 => mapping(address => address)) public uplineTwo;
    mapping(uint256 => uint256) public currentEmptyPos;
    uint256 public emptyPos = 0;
    uint256 public packageInd;

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
        address uplineOne,
        address uplineTwo
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
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    receive() external payable {}

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);

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
    }

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

    function distribute2USDT() internal {
        uint256 usdtToDistribute = 2 * 10**18; // 2 USDT

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
        for (uint256 i = 1; i < packagePrices.length; i++) {
            currentEmptyPos[i] = emptyPos;
            // Update user's package index
            userPackages[owner()] = i;
            users[i][currentEmptyPos[i]] = owner();
            uplineOne[i][owner()] = address(0);
            uplineTwo[i][owner()] = address(0);
            uint256 packagePrice = packagePrices[i];

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

    function globalPurchase(uint256 packageIndex) external {
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );
        uint256 currentPackageIndex = userPackages[msg.sender];
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

        uint256 packagePrice = packagePrices[packageIndex];
        uint256 remainingAmount = packagePrice - 2 * 10**18;
        uint256 amountToDistribute = remainingAmount / 2;
        userPackages[user] = packageIndex;
        packageInd = packageIndex;

        usdtToken.approve(address(this), packagePrice);
        usdtToken.transferFrom(user, address(this), packagePrice);

        users[packageIndex][currentEmptyPos[packageIndex]] = user;

        if (
            currentEmptyPos[packageIndex] == 1 ||
            currentEmptyPos[packageIndex] == 2 ||
            currentEmptyPos[packageIndex] == 3
        ) {
            uplineOne[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();
            usdtToken.transfer(
                uplineOne[packageIndex][user],
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
            uplineOne[packageIndex][user] = users[packageIndex][1];
            uplineTwo[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();
            usdtToken.transfer(
                uplineOne[packageIndex][user],
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
            uplineOne[packageIndex][user] = users[packageIndex][1];
            uplineTwo[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();
            usdtToken.transfer(
                uplineOne[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(
                uplineTwo[packageIndex][user],
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
            uplineOne[packageIndex][user] = users[packageIndex][2];
            uplineTwo[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();
            usdtToken.transfer(
                uplineOne[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(
                uplineTwo[packageIndex][user],
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
            uplineOne[packageIndex][user] = users[packageIndex][3];
            uplineTwo[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();

            usdtToken.transfer(
                uplineOne[packageIndex][user],
                amountToDistribute
            );
            usdtToken.transfer(
                uplineTwo[packageIndex][user],
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
            uplineOne[packageIndex][user] = users[packageIndex][3];
            uplineTwo[packageIndex][user] = users[packageIndex][0];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();

            usdtToken.transfer(
                uplineOne[packageIndex][user],
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

            uplineOne[packageIndex][user] = users[packageIndex][uplinePos];
            updateAndSetDistributionAddresses(referrer, packageIndex);
            distribute2USDT();

            usdtToken.transfer(
                uplineOne[packageIndex][user],
                amountToDistribute
            );

            uint256 pos = currentEmptyPos[packageIndex];
            if (isRecyclePos11(pos)) {
                currentEmptyPos[packageIndex] += 1;
                uplineTwo[packageIndex][user] = uplineOne[packageIndex][
                    users[packageIndex][uplinePos]
                ];

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
                    uplineOne[packageInd][msg.sender],
                    uplineTwo[packageInd][msg.sender]
                );
            } else if (isRecyclePos12(pos)) {
                currentEmptyPos[packageIndex] += 1;
                uplineTwo[packageIndex][user] = uplineOne[packageIndex][
                    users[packageIndex][uplinePos]
                ];

                currentEmptyPos[packageIndex] += 1;
                uint256 uplinePosRecycle = findUpline(
                    currentEmptyPos[packageIndex]
                );
                address structureUpline2 = uplineTwo[packageIndex][user];
                uplineOne[packageIndex][structureUpline2] = users[packageIndex][
                    uplinePosRecycle
                ];
                uplineTwo[packageIndex][structureUpline2] = uplineOne[
                    packageIndex
                ][uplineOne[packageIndex][structureUpline2]];

                usdtToken.transfer(
                    uplineOne[packageIndex][structureUpline2],
                    amountToDistribute
                );
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
                    false,
                    false,
                    true,
                    uplineOne[packageInd][msg.sender],
                    uplineTwo[packageInd][msg.sender]
                );

                emit PackagePurchased(
                    structureUpline2,
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
                    uplineOne[packageInd][structureUpline2],
                    uplineTwo[packageInd][structureUpline2]
                );
            } else if (isRoyalty(pos)) {
                currentEmptyPos[packageIndex] += 1;
                uplineTwo[packageIndex][user] = uplineOne[packageIndex][
                    users[packageIndex][uplinePos]
                ];
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
                    uplineOne[packageInd][msg.sender],
                    uplineTwo[packageInd][msg.sender]
                );
            } else {
                currentEmptyPos[packageIndex] += 1;
                uplineTwo[packageIndex][user] = uplineOne[packageIndex][
                    users[packageIndex][uplinePos]
                ];
                usdtToken.transfer(
                    uplineTwo[packageIndex][user],
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
                    uplineOne[packageInd][msg.sender],
                    uplineTwo[packageInd][msg.sender]
                );
            }
        }
    }

    function withdrawUSDT(uint256 amount) public onlyOwner {
        usdtToken.transfer(owner(), amount);
    }
}
