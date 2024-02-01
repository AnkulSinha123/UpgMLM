// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./Registration.sol";

contract RoyaltyBonus is Initializable, OwnableUpgradeable {
    uint256 public royaltyPercentage;
    address public royaltyRecipient;

    // event RoyaltyPaid(address indexed recipient, uint256 amount);

    // function initialize(uint256 _royaltyPercentage, address _royaltyRecipient, address initialOwner) public initializer {

    // }

    // function setRoyalty(uint256 _royaltyPercentage, address _royaltyRecipient) public onlyOwner {
  
    // }

    // function payRoyalty(uint256 amount) external {
   
    // }
}