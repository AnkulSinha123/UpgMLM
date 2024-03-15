// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/token/ERC20/ERC20Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./Pro_Power_Matrix.sol";

contract Upgraded {
    IERC20 public usdtToken;
    address payable public RoyaltyContract;
    RegistrationInterface public registration;
    address public owner;
    Pro_Power_Matrix public Pro;

    // Declare payable addresses for upline
    address payable public upline1;
    address payable public upline2;
    address payable public upline3;
    address payable public upline4;
    address payable public upline5;
    address payable public structureUpline1;
    address payable public structureUpline2;
    address payable public uplineToUplineOFStructureUpline2;

    uint256[] public packagePrices;
    mapping(address => uint256) public newUserPackages;

    constructor() {
        owner = msg.sender;

        upline1 = payable(owner);
        upline2 = payable(owner);
        upline3 = payable(owner);
        upline4 = payable(owner);
        upline5 = payable(owner);
        structureUpline1 = payable(owner);
        structureUpline2 = payable(owner);

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
    }

    // Constants for distribution percentages
    uint256 private constant upline1_PERCENTAGE = 40;
    uint256 private constant upline2_PERCENTAGE = 25;
    uint256 private constant upline3_PERCENTAGE = 15;
    uint256 private constant upline4_PERCENTAGE = 10;
    uint256 private constant upline5_PERCENTAGE = 10;

    mapping(uint256 => mapping(address => address)) public userStructureUpline1;
    mapping(uint256 => mapping(address => address[])) public newDownlines;
    mapping(uint256 => mapping(address => address[]))
        public newSecondLayerDownlines;

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

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
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

    function setPro(address payable _pro) external onlyOwner {
        Pro = Pro_Power_Matrix(_pro);
    }

    function getUserPackage(address user)
        public
        view
        returns (uint)
    {
        return Pro.userPackages(user);
    }

    function setPackage(address[] calldata users) external onlyOwner {
    for (uint256 i = 0; i < users.length; i++) {
        address user = users[i];
        uint packageUser = getUserPackage(user);
        newUserPackages[user] = packageUser;
    }
}

    function getUserStructureUpline1(uint256 _packageIndex, address user)
        public
        view
        returns (address)
    {
        return Pro.upline(_packageIndex, user);
    }

    function getDownlines(
        uint256 packageIndex,
        address user,
        uint256 pos
    ) public view returns (address) {
        return Pro.downlines(packageIndex, user, pos);
    }

    function getSecDownlines(
        uint256 packageIndex,
        address user,
        uint256 pos
    ) public view returns (address) {
        return Pro.secondLayerDownlines(packageIndex, user, pos);
    }

    function setUserStructureUpline1(
        address[] calldata users,
        uint256 packageIndex
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            address _structure1Upline = getUserStructureUpline1(
                packageIndex,
                user
            );
            userStructureUpline1[packageIndex][user] = _structure1Upline;
        }
    }

    function setDownlinesForUsers(
        address[] calldata users,
        uint256 packageIndex,
        uint256 pos
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            address downline = getDownlines(packageIndex, user, pos);
            newDownlines[packageIndex][user].push(downline);
        }
    }

    function setSecDownlinesForUsers(
        address[] calldata users,
        uint256 packageIndex,
        uint256 pos
    ) external onlyOwner {
        for (uint256 i = 0; i < users.length; i++) {
            address user = users[i];
            address secDownline = getSecDownlines(packageIndex, user, pos);            
            newSecondLayerDownlines[packageIndex][user].push(secDownline);
        }
    }

    function updateAndSetDistributionAddresses(
        address currentUpline,
        uint256 packageIndex
    ) internal {
        address userUpline = currentUpline;

        uint256 qualifiedUplinesFound = 0;

        // Iterate through uplines until 5 qualified uplines are found or until the user's package index is greater than or equal to the upline's package index
        while (userUpline != address(0) && qualifiedUplinesFound < 5) {
            if (newUserPackages[userUpline] >= packageIndex) {
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
            address referrer = Pro.getUserInfo(userUpline).referrer;
            while (
                referrer != address(0) && newUserPackages[referrer] < packageIndex
            ) {
                referrer = Pro.getUserInfo(referrer).referrer;
            }

            if (referrer == address(0)) {
                break; // Break the loop if no referrer with a matching or higher package index is found
            }

            userUpline = referrer;
        }

        // If upline1, upline2, upline3, upline4, or upline5 are not set, set them to the contract owner()
        if (qualifiedUplinesFound < 1) {
            upline1 = payable(owner);
        }

        if (qualifiedUplinesFound < 2) {
            upline2 = payable(owner);
        }

        if (qualifiedUplinesFound < 3) {
            upline3 = payable(owner);
        }

        if (qualifiedUplinesFound < 4) {
            upline4 = payable(owner);
        }

        if (qualifiedUplinesFound < 5) {
            upline5 = payable(owner);
        }
    }

    function updatePurchasePackage(uint256 packageIndex) external{
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = newUserPackages[msg.sender];

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
        require(Pro.getUserInfo(msg.sender).isRegistered, "Not registered");

        address referrerAddress = Pro.getUserInfo(msg.sender).referrer;
        userStructureUpline1[packageIndex][msg.sender] = referrerAddress;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Distribute 2 USDT among levels 1 to 5 (deducted from the package price)
        distribute2USDT();

        uint256 remainingAmount = packagePrice - 2 * 10**18;

        // Check if the specified upline already has 4 downlines
        if (newDownlines[packageIndex][upline1].length < 4) {
            newDownlines[packageIndex][upline1].push(msg.sender);
            userStructureUpline1[packageIndex][msg.sender] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(userStructureUpline1[packageIndex][structureUpline1]);

            if (upline1 != owner) {
                newSecondLayerDownlines[packageIndex][structureUpline2].push(
                    msg.sender
                );
            }
        } else {
            for (
                uint256 i = 0;
                i < newDownlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = newDownlines[packageIndex][upline1][i];
                if (downlineAddress != address(0)) {
                    if (newDownlines[packageIndex][downlineAddress].length < 4) {
                        newDownlines[packageIndex][downlineAddress].push(
                            msg.sender
                        );
                        userStructureUpline1[packageIndex][msg.sender] = downlineAddress;
                        structureUpline1 = payable(downlineAddress);
                        structureUpline2 = payable(
                            userStructureUpline1[packageIndex][downlineAddress]
                        );

                        if (downlineAddress != owner) {
                            newSecondLayerDownlines[packageIndex][structureUpline2]
                                .push(msg.sender);
                        }
                        break;
                    }
                }
            }
        }
        usdtToken.transfer(structureUpline1, remainingAmount / 2);
        distributeUSDT(structureUpline2, remainingAmount / 2, packageIndex);
        if (newSecondLayerDownlines[packageIndex][structureUpline2].length == 16) {
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
        if (newSecondLayerDownlines[packageIndex][structureUpline2].length == 16) {
            updateRecycleProcess(packageIndex, remainingAmount, structureUpline2);
        }

        // Remove the user from the downlines of their previous upline
        newUserPackages[msg.sender] = packageIndex;
    }

    function updateRecycleProcess(
        uint256 packageIndex,
        uint256 remaining,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = userStructureUpline1[packageIndex][structureUpline2];
        address uplineToUplineOfStructure2 = userStructureUpline1[packageIndex][
            userStructureUpline1[packageIndex][structureUpline2]
        ];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (newSecondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (structureUpline2 == owner)
        ) {
            newDownlines[packageIndex][owner] = new address[](0);
            newSecondLayerDownlines[packageIndex][owner] = new address[](0);

            emit PackagePurchased(
                owner,
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
            (newSecondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (UplineOfStructure2 != address(0))
        ) {
            if (newDownlines[packageIndex][UplineOfStructure2].length < 4) {
                newDownlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner) {
                    newSecondLayerDownlines[packageIndex][
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

                uint256 secondaryLine = newSecondLayerDownlines[packageIndex][
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
                    updateRecycleProcess(
                        packageIndex,
                        remaining,
                        uplineToUplineOfStructure2
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < newDownlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = newDownlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (downlineOfUplineOfStructure2 != address(0)) {
                        if (
                            newDownlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].length < 4
                        ) {
                            newDownlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].push(structureUpline2);
                            userStructureUpline1[packageIndex][
                                structureUpline2
                            ] = downlineOfUplineOfStructure2;
                            uplineToUplineOFStructureUpline2 = payable(
                                userStructureUpline1[packageIndex][
                                    downlineOfUplineOfStructure2
                                ]
                            );

                            if (downlineOfUplineOfStructure2 != owner) {
                                newSecondLayerDownlines[packageIndex][
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

                            uint256 secondaryLine = newSecondLayerDownlines[
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
                                updateRecycleProcess(
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
        address[] storage secondLayer = newSecondLayerDownlines[packageIndex][
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

    function clearDownlines(
        address uplineToRecycle,
        address uplineOfUpline2,
        uint256 packageIndex
    ) internal {
        address[] storage downlineAddresses = newDownlines[packageIndex][
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
        newDownlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function clearSecondLayerDownlines(
        address uplineToRecycle,
        address secUplineOfUpline2,
        uint256 packageIndex
    ) internal {
        address[] storage secdownlineAddresses = newSecondLayerDownlines[
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
        newSecondLayerDownlines[packageIndex][uplineToRecycle] = new address[](0);
    }

    function updateProvidePackage(uint256 packageIndex, address user)
        internal
        onlyOwner
    {
        require(
            packageIndex > 0 && packageIndex < packagePrices.length,
            "Invalid package index"
        );

        uint256 currentPackageIndex = newUserPackages[user];

        // Check if the user has any existing package or if they are purchasing the next package in sequence
        require(
            packageIndex == currentPackageIndex + 1,
            "Must provide packages sequentially"
        );

        // Check if the user is registered
        require(Pro.getUserInfo(user).isRegistered, "User is not registered");

        address referrerAddress = Pro.getUserInfo(user).referrer;

        // Check if the referrer address is valid
        require(referrerAddress != address(0), "Referrer not found");

        userStructureUpline1[packageIndex][user] = referrerAddress;

        updateAndSetDistributionAddresses(referrerAddress, packageIndex);

        // Check if the specified upline already has 4 downlines
        if (newDownlines[packageIndex][upline1].length < 4) {
            newDownlines[packageIndex][upline1].push(user);
            userStructureUpline1[packageIndex][user] = upline1;
            structureUpline1 = upline1;
            structureUpline2 = payable(userStructureUpline1[packageIndex][structureUpline1]);

            if (upline1 != owner) {
                newSecondLayerDownlines[packageIndex][structureUpline2].push(user);
            }
        } else {
            for (
                uint256 i = 0;
                i < newDownlines[packageIndex][upline1].length;
                i++
            ) {
                address downlineAddress = newDownlines[packageIndex][upline1][i];
                if (downlineAddress != address(0)) {
                    if (newDownlines[packageIndex][downlineAddress].length < 4) {
                        newDownlines[packageIndex][downlineAddress].push(user);
                        userStructureUpline1[packageIndex][user] = downlineAddress;
                        structureUpline1 = payable(downlineAddress);
                        structureUpline2 = payable(
                            userStructureUpline1[packageIndex][downlineAddress]
                        );
                        if (structureUpline1 != owner) {
                            newSecondLayerDownlines[packageIndex][structureUpline2]
                                .push(user);
                        }
                        break;
                    }
                }
            }
        }

        address[] storage secondLayer = newSecondLayerDownlines[packageIndex][
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
            updateRecycleProvidePackage(packageIndex, structureUpline2);
        }
        newUserPackages[user] = packageIndex;
    }

    function updateRecycleProvidePackagesBulk(
        uint256 endPackageIndex,
        address[] calldata users
    ) external onlyOwner {
        uint256 startPackageIndex;
        for (uint256 j = 0; j < users.length; j++) {
            startPackageIndex = newUserPackages[users[j]] + 1;
            require(
                startPackageIndex > 0 &&
                    endPackageIndex < packagePrices.length &&
                    startPackageIndex <= endPackageIndex,
                "Invalid package indexes"
            );

            for (uint256 i = startPackageIndex; i <= endPackageIndex; i++) {
                updateProvidePackage(i, users[j]);
            }
        }
    }

    function updateRecycleProvidePackage(
        uint256 packageIndex,
        address structureUpline2
    ) internal {
        address UplineOfStructure2 = userStructureUpline1[packageIndex][structureUpline2];
        address uplineToUplineOfStructure2 = userStructureUpline1[packageIndex][
            userStructureUpline1[packageIndex][structureUpline2]
        ];
        uint256 packagePrice = packagePrices[packageIndex];

        if (
            (newSecondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (structureUpline2 == owner)
        ) {
            newDownlines[packageIndex][owner] = new address[](0);
            newSecondLayerDownlines[packageIndex][owner] = new address[](0);
            emit PackagePurchased(
                owner,
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
            (newSecondLayerDownlines[packageIndex][structureUpline2].length ==
                16) && (UplineOfStructure2 != address(0))
        ) {
            if (newDownlines[packageIndex][UplineOfStructure2].length < 4) {
                newDownlines[packageIndex][UplineOfStructure2].push(
                    structureUpline2
                );
                if (UplineOfStructure2 != owner) {
                    newSecondLayerDownlines[packageIndex][
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

                uint256 secondaryLine = newSecondLayerDownlines[packageIndex][
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
                    updateRecycleProvidePackage(
                        packageIndex,
                        uplineToUplineOfStructure2
                    );
                }
            } else {
                for (
                    uint256 i = 0;
                    i < newDownlines[packageIndex][UplineOfStructure2].length;
                    i++
                ) {
                    address downlineOfUplineOfStructure2 = newDownlines[
                        packageIndex
                    ][UplineOfStructure2][i];
                    if (downlineOfUplineOfStructure2 != address(0)) {
                        if (
                            newDownlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].length < 4
                        ) {
                            newDownlines[packageIndex][
                                downlineOfUplineOfStructure2
                            ].push(structureUpline2);
                            userStructureUpline1[packageIndex][
                                structureUpline2
                            ] = downlineOfUplineOfStructure2;
                            uplineToUplineOFStructureUpline2 = payable(
                                userStructureUpline1[packageIndex][
                                    downlineOfUplineOfStructure2
                                ]
                            );

                            if (downlineOfUplineOfStructure2 != owner) {
                                newSecondLayerDownlines[packageIndex][
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

                            uint256 secondaryLine = newSecondLayerDownlines[
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
                                updateRecycleProvidePackage(
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
}