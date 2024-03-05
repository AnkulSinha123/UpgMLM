// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

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

contract Pro_Global is Initializable, OwnableUpgradeable {
    
    uint256[] public packagePrices;
    mapping(address => uint256) public userPackages;
    mapping(uint256 => address) public users;
    mapping(address => address) public uplineOne;
    mapping(address => address) public uplineTwo;
    uint256 public currentEmptyPos = 0;

    struct UserInfo {
        address referrer;
        address[] referrals;
        bool isRegistered;
        string userUniqueId;
    }

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

    function isRecyclePos(uint256 pos) internal pure returns (bool) {
        if (pos == 2 || pos == 3) {
            return false;
        } else if (pos == 11 || (pos - 11) % 9 == 0) {
            return true;
        } else if (pos == 12 || (pos - 12) % 9 == 0) {
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

    function globalPurchase(uint256 packageIndex) external {
        require(packageIndex > 0 && packageIndex < packagePrices.length,"Invalid package index");
        uint256 currentPackageIndex = userPackages[msg.sender];
        require(packageIndex == currentPackageIndex + 1,"Purchase packages sequentially");

        require(getUserInfo(msg.sender).isRegistered, "Not registered");
        require(users[currentEmptyPos] == address(0), "Position is not empty");

        uint256 packagePrice = packagePrices[packageIndex];

        usdtToken.approve(address(this), packagePrice);
        usdtToken.transferFrom(msg.sender, address(this), packagePrice);
        
        address user = msg.sender;
        users[currentEmptyPos] = user;
        if (currentEmptyPos == 0) {
            uplineOne[user] = address(0);
            uplineTwo[user] = address(0);
            currentEmptyPos += 1;
            return;
        }

        if(currentEmptyPos == 1 || currentEmptyPos == 2 || currentEmptyPos == 3) {
            uplineOne[user] = users[0];
            currentEmptyPos += 1;
            return;
        }
        else if(currentEmptyPos == 4 || currentEmptyPos == 5|| currentEmptyPos == 6) {
            uplineOne[user] = users[1];
            uplineTwo[user] = users[0];
            currentEmptyPos += 1;
            return;
        }else if(currentEmptyPos == 7 || currentEmptyPos == 8 || currentEmptyPos == 9) {
            uplineOne[user] = users[2];
            uplineTwo[user] = users[0];
            currentEmptyPos += 1;
            return;
        }else if(currentEmptyPos == 10 || currentEmptyPos == 11 || currentEmptyPos == 12) {
            uplineOne[user] = users[3];
            uplineTwo[user] = users[0];
            currentEmptyPos += 1;
            return;
        }
        else{
        uint256 uplinePos = findUpline(currentEmptyPos);
        // transfer money to upline1
        uplineOne[user] = users[uplinePos];
        
        uint256 pos = currentEmptyPos;
        if (isRecyclePos(pos)) {
            currentEmptyPos += 1;
            uplineTwo[user] = uplineOne[users[uplinePos]];
        } else if (isRoyalty(pos)) {
            currentEmptyPos += 1;
            uplineTwo[user] = uplineOne[users[uplinePos]];
        } else {
            currentEmptyPos += 1;
            uplineTwo[user] = uplineOne[users[uplinePos]];
        }
    }
    }

    function withdrawUSDT(uint256 amount) public onlyOwner {
        usdtToken.transfer(owner(), amount);
    }
}
