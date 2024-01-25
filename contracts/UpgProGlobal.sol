// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";

contract MLM is Initializable, OwnableUpgradeable {
    address public usdtToken; // Tether (USDT) contract address
    address public bnbToken;  // BNB contract address

    uint256 public registrationFee;

    struct UserInfo {
        address referrer;
        address[] referrals;
    }

    mapping(address => UserInfo) public users;

    event UserRegistered(address indexed user, address indexed referrer);

    modifier onlyRegistered() {
        require(users[msg.sender].referrer != address(0), "User not registered");
        _;
    }

    function initialize(address _usdtToken, address _bnbToken, uint256 _registrationFee, address initialOwner) public initializer {
        __Ownable_init(initialOwner); // Call the initializer from OwnableUpgradeable
        usdtToken = _usdtToken;
        bnbToken = _bnbToken;
        registrationFee = _registrationFee;
    }

    function setRegistrationFee(uint256 _registrationFee) external onlyOwner {
        registrationFee = _registrationFee;
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
    }

    function getReferrals(address user) external view returns (address[] memory) {
        return users[user].referrals;
    }

    

    function withdraw() external onlyOwner {
        IERC20(usdtToken).transfer(owner(), IERC20(usdtToken).balanceOf(address(this)));
    }
}
