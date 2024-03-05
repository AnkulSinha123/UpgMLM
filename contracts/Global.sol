// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MLMContract {

    mapping(uint256 => address) public users;
    mapping(address => address) public upline1;
    mapping(address => address) public upline2;
    uint256 public currentEmptyPos = 0;

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

    function isRoyalty(uint256 pos) public pure returns (bool) {
        if (pos == 4 || pos == 5) {
            return true;
        }
        if ((pos - 4) % 9 == 0 || (pos - 5) % 9 == 0) {
            return true;
        }
        return false;
    }

    function findUpline(uint256 pos) public pure returns (uint256) {
        if (pos % 3 == 0) {
            return pos / 3 - 1;
        }
        return pos / 3;
    }

    function addUser() external {
        require(users[currentEmptyPos] == address(0), "Position is not empty");
        
        address user = msg.sender;
        users[currentEmptyPos] = user;
        if (currentEmptyPos == 0) {
            upline1[user] = address(0);
            upline2[user] = address(0);
            currentEmptyPos += 1;
            return;
        }

        if(currentEmptyPos == 1 || currentEmptyPos == 2 || currentEmptyPos == 3) {
            upline1[user] = users[0];
            currentEmptyPos += 1;
            return;
        }
        else if(currentEmptyPos == 4 || currentEmptyPos == 5|| currentEmptyPos == 6) {
            upline1[user] = users[1];
            upline2[user] = users[0];
            currentEmptyPos += 1;
            return;
        }else if(currentEmptyPos == 7 || currentEmptyPos == 8 || currentEmptyPos == 9) {
            upline1[user] = users[2];
            upline2[user] = users[0];
            currentEmptyPos += 1;
            return;
        }else if(currentEmptyPos == 10 || currentEmptyPos == 11 || currentEmptyPos == 12) {
            upline1[user] = users[3];
            upline2[user] = users[0];
            currentEmptyPos += 1;
            return;
        }
        else{
        uint256 uplinePos = findUpline(currentEmptyPos);
        // transfer money to upline1
        upline1[user] = users[uplinePos];
        uint256 pos = currentEmptyPos;
        if (isRecyclePos(pos)) {
            currentEmptyPos += 1;
            upline2[user] = upline1[users[uplinePos]];
        } else if (isRoyalty(pos)) {
            currentEmptyPos += 1;
            upline2[user] = upline1[users[uplinePos]];
        } else {
            currentEmptyPos += 1;
            upline2[user] = upline1[users[uplinePos]];
        }
    }
    }
}