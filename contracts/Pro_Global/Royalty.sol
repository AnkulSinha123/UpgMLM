// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

interface IERC20 {
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );

    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address to, uint256 value) external returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 value) external returns (bool);

    function transferFrom(
        address from,
        address to,
        uint256 value
    ) external returns (bool);
}

contract MillionaireRoyalty is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 public marsDistAmount;
    uint256 public moonDistAmount;
    uint256 public saturnDistAmount;
    uint256 public sunDistAmount;

    event withdrawal(address user, uint256 amount);

    IERC20 public usdtToken;

    mapping(address => uint256) public balances;

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    receive() external payable {}

    function checkBalance() external view returns (uint256) {
        return balances[msg.sender];
    }

    function withdrawRoyalty() external {
        uint256 amount = balances[msg.sender];
        usdtToken.transfer(msg.sender, amount);

        emit withdrawal(msg.sender, amount);
    }

    function setUSDT(address _usdtToken) external onlyOwner {
        usdtToken = IERC20(_usdtToken);
    }

    function setDistributionAmounts() external onlyOwner {
        uint256 totalBalance = usdtToken.balanceOf(address(this));
        require(totalBalance > 0, "Total balance is zero");

        uint256 _marsAmount = (totalBalance * 10) / 100;
        marsDistAmount = _marsAmount;
        uint256 _moonAmount = (totalBalance * 15) / 100;
        moonDistAmount = _moonAmount;
        uint256 _saturnAmount = (totalBalance * 30) / 100;
        saturnDistAmount = _saturnAmount;
        uint256 _sunAmount = (totalBalance * 45) / 100;
        sunDistAmount = _sunAmount;
    }

    function mars(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = marsDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            balances[recipients[i]] += amountPerRecipient;
        }
    }

    function moon(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = moonDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            balances[recipients[i]] += amountPerRecipient;
        }
    }

    function saturn(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = saturnDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            balances[recipients[i]] += amountPerRecipient;
        }
    }

    function sun(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = sunDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            balances[recipients[i]] += amountPerRecipient;
        }
    }

    function withdrawUSDT(uint256 amount) public onlyOwner {
        usdtToken.transfer(owner(), amount);
    }

    function withdrawBNB(uint256 amount) external onlyOwner {
        payable(owner()).transfer(amount);
    }
}
