// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MLM is Initializable, OwnableUpgradeable {
    address public usdtToken; // Tether (USDT) contract address
    address public bnbToken;  // BNB contract address

    uint256 public registrationFee;
    uint256 public distributionPercentage; // Percentage to distribute from registration fee

    struct UserInfo {
        address referrer;
        address[] referrals;
    }

    mapping(address => UserInfo) public users;

    event UserRegistered(address indexed user, address indexed referrer);
    event Distribution(address indexed recipient, uint256 amount);

    modifier onlyRegistered() {
        require(users[msg.sender].referrer != address(0), "User not registered");
        _;
    }

    function initialize(address _usdtToken, address _bnbToken, uint256 _registrationFee, uint256 _distributionPercentage, address initialOwner) public initializer {
        __Ownable_init(initialOwner); // Call the initializer from OwnableUpgradeable
        usdtToken = _usdtToken;
        bnbToken = _bnbToken;
        registrationFee = _registrationFee;
        distributionPercentage = _distributionPercentage;
    }

    function setRegistrationFee(uint256 _registrationFee) external onlyOwner {
        registrationFee = _registrationFee;
    }

    function setDistributionPercentage(uint256 _distributionPercentage) external onlyOwner {
        require(_distributionPercentage <= 100, "Percentage must be <= 100");
        distributionPercentage = _distributionPercentage;
    }

    function register(address referrer) external {
        require(users[referrer].referrer != address(0) || referrer == owner(), "Referrer not registered");
        require(users[msg.sender].referrer == address(0), "User already registered");
        require(IERC20(usdtToken).allowance(msg.sender, address(this)) >= registrationFee, "Insufficient allowance for registration");
        require(IERC20(usdtToken).balanceOf(msg.sender) >= registrationFee, "Insufficient USDT balance for registration");

        IERC20(usdtToken).transferFrom(msg.sender, address(this), registrationFee);

        users[msg.sender].referrer = referrer;
        users[referrer].referrals.push(msg.sender);

        emit UserRegistered(msg.sender, referrer);

        // Distribute a portion of the registration fee to multiple levels
        distributeRegistrationFee(msg.sender, registrationFee);
    }

    function distributeRegistrationFee(address user, uint256 amount) internal {
    address currentReferrer = users[user].referrer;

    // Distribute to the first level (level 1)
    if (currentReferrer != address(0)) {
        uint256 level1Amount = (amount * 40) / 100; // 40% to level 1
        IERC20(usdtToken).transfer(currentReferrer, level1Amount);

        emit Distribution(currentReferrer, level1Amount);

        // Distribute to the second level (level 2)
        address level2Referrer = users[currentReferrer].referrer;
        if (level2Referrer != address(0)) {
            uint256 level2Amount = (amount * 25) / 100; // 25% to level 2
            IERC20(usdtToken).transfer(level2Referrer, level2Amount);

            emit Distribution(level2Referrer, level2Amount);

            // Distribute to the third level (level 3)
            address level3Referrer = users[level2Referrer].referrer;
            if (level3Referrer != address(0)) {
                uint256 level3Amount = (amount * 15) / 100; // 15% to level 3
                IERC20(usdtToken).transfer(level3Referrer, level3Amount);

                emit Distribution(level3Referrer, level3Amount);

                // Distribute to the fourth level (level 4)
                address level4Referrer = users[level3Referrer].referrer;
                if (level4Referrer != address(0)) {
                    uint256 level4Amount = (amount * 10) / 100; // 10% to level 4
                    IERC20(usdtToken).transfer(level4Referrer, level4Amount);

                    emit Distribution(level4Referrer, level4Amount);

                    // Distribute to the fifth level (level 5)
                    address level5Referrer = users[level4Referrer].referrer;
                    if (level5Referrer != address(0)) {
                        uint256 level5Amount = (amount * 10) / 100; // 10% to level 5
                        IERC20(usdtToken).transfer(level5Referrer, level5Amount);

                        emit Distribution(level5Referrer, level5Amount);
                    }
                }
            }
        }
    }
}


    function getReferrals(address user) external view returns (address[] memory) {
        return users[user].referrals;
    }

    function withdraw() external onlyOwner {
        IERC20(usdtToken).transfer(owner(), IERC20(usdtToken).balanceOf(address(this)));
    }
}
