// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract Royalty {
    address public owner;

    uint256 public marsDistAmount;
    uint256 public moonDistAmount;
    uint256 public saturnDistAmount;
    uint256 public sunDistAmount;

    IERC20 public usdtToken;

    constructor() {
        owner = msg.sender;
    }

    receive() external payable {}

    modifier onlyOwner() {
        require(msg.sender == owner, "Not Owner");
        _;
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
            usdtToken.transfer(recipients[i], amountPerRecipient);
        }
    }

    function moon(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = moonDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            usdtToken.transfer(recipients[i], amountPerRecipient);
        }
    }

    function saturn(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = saturnDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            usdtToken.transfer(recipients[i], amountPerRecipient);
        }
    }

    function sun(address[] memory recipients) external onlyOwner {
        require(recipients.length > 0, "No recipients provided");
        uint256 numRecipients = recipients.length;
        uint256 amountPerRecipient = sunDistAmount / numRecipients;

        for (uint256 i = 0; i < numRecipients; i++) {
            usdtToken.transfer(recipients[i], amountPerRecipient);
        }
    }

    function withdrawUSDT(uint256 amount) public onlyOwner {
        usdtToken.transfer(owner, amount);
    }
}
