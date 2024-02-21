// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Royalty {

function qualifiesForRoyalty(address user) internal view returns (bool) {
    uint256 totalTeamMembers = getTotalTeamMembers(user);
    uint256 qualifiedTeamMembers = getQualifiedTeamMembers(user);
    
    return (totalTeamMembers >= 200 && qualifiedTeamMembers >= 200);
}

function getTotalTeamMembers(address user) internal view returns (uint256) {

}

function getQualifiedTeamMembers(address user) internal view returns (uint256) {

}
}