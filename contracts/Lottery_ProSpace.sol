// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import "./Registration.sol";

contract MetaProSpaceLuckyDraw is
    Initializable,
    OwnableUpgradeable,
    UUPSUpgradeable
{
    uint256 public entryFee;
    uint256 public maxParticipants;
    uint256 public totalDeposit;
    uint256 public totalDistribution;
    uint256 public withdrawFee;

    address[] public participants;
    mapping(address => bool) public hasParticipated;
    mapping(uint256 => uint256) public prizeDistribution;
    mapping(address => uint256) public prizeAmount;

    IERC20 public usdtToken;
    Registration public registration;

    event ParticipantEntered(address indexed participant);
    event PrizesDistributed();
    event PrizeWithdrawn(address indexed participant, uint256 amount);
    event FundsWithdrawn(uint256 amount);

    function initialize(address initialOwner) public initializer {
        __Ownable_init(initialOwner);
        __UUPSUpgradeable_init();

        entryFee = 10 * 1e18; // 10 USD in wei (assuming 1 USD = 1 USDT)
        maxParticipants = 10000;
        totalDeposit = 0;
        totalDistribution = 100000 * 1e18; // 100,000 USD in wei
        withdrawFee = 10; // 10%
    }

    function _authorizeUpgrade(address newImplementation)
        internal
        override
        onlyOwner
    {}

    function _setPrizeDistribution() external onlyOwner {
        for (uint256 i = 51; i <= 200; i++) {
            prizeDistribution[i] = 50 * 1e18;
        }
        for (uint256 i = 501; i <= 1000; i++) {
            prizeDistribution[i] = 20 * 1e18;
        }
        for (uint256 i = 1001; i <= 2000; i++) {
            prizeDistribution[i] = 15 * 1e18;
        }
    }

    function _setPrizeDistribution2() external onlyOwner {
        prizeDistribution[1] = 1000 * 1e18;
        prizeDistribution[2] = 750 * 1e18;
        prizeDistribution[3] = 500 * 1e18;
        prizeDistribution[4] = 400 * 1e18;
        prizeDistribution[5] = 300 * 1e18;

        for (uint256 i = 2001; i <= 5000; i++) {
            prizeDistribution[i] = 10 * 1e18;
        }

        for (uint256 i = 5001; i <= 8000; i++) {
            prizeDistribution[i] = 5 * 1e18;
        }
    }

    function _setPrizeDistribution3() external onlyOwner {
        for (uint256 i = 6; i <= 10; i++) {
            prizeDistribution[i] = 200 * 1e18;
        }
        for (uint256 i = 11; i <= 50; i++) {
            prizeDistribution[i] = 100 * 1e18;
        }
        for (uint256 i = 201; i <= 500; i++) {
            prizeDistribution[i] = 30 * 1e18;
        }
        for (uint256 i = 8001; i <= 9850; i++) {
            prizeDistribution[i] = 3 * 1e18;
        }
    }

    function setUSDT(address _usdtToken) external onlyOwner {
        usdtToken = IERC20(_usdtToken);
    }

    function setRegistration(address _registrationAddress) external onlyOwner {
        registration = Registration(_registrationAddress);
    }

    function enter() public {
        require(
            registration.getUserInfo(msg.sender).isRegistered,
            "Not registered"
        );
        require(
            usdtToken.transferFrom(msg.sender, address(this), entryFee),
            "Transfer failed"
        );
        require(
            participants.length < maxParticipants,
            "Max participants reached"
        );
        require(!hasParticipated[msg.sender], "Already participated");

        participants.push(msg.sender);
        hasParticipated[msg.sender] = true;
        totalDeposit += entryFee;

        emit ParticipantEntered(msg.sender);
    }

    function distributePrizes() public onlyOwner {
        require(participants.length > 0, "No participants to distribute");

        _shuffle(participants);

        for (uint256 i = 0; i < participants.length; i++) {
            uint256 prize = prizeDistribution[i + 1];
            if (prize > 0) {
                prizeAmount[participants[i]] = prize;
            }
        }

        emit PrizesDistributed();
    }

    function withdrawPrize() public {
        uint256 prize = prizeAmount[msg.sender];
        require(prize > 0, "No prize to withdraw");

        prizeAmount[msg.sender] = 0;
        usdtToken.transfer(msg.sender, prize);

        emit PrizeWithdrawn(msg.sender, prize);
    }

    function withdraw() public onlyOwner {
        uint256 balance = usdtToken.balanceOf(address(this));
        require(balance > 0, "No funds to withdraw");

        uint256 fee = (balance * withdrawFee) / 100;
        uint256 amountToWithdraw = balance - fee;

        usdtToken.transfer(owner(), amountToWithdraw);

        emit FundsWithdrawn(amountToWithdraw);
    }

    function getParticipants() public view returns (address[] memory) {
        return participants;
    }

    function _shuffle(address[] storage array) internal {
        for (uint256 i = array.length - 1; i > 0; i--) {
            uint256 j = uint256(
                keccak256(
                    abi.encodePacked(
                        block.timestamp,
                        block.difficulty,
                        msg.sender
                    )
                )
            ) % (i + 1);
            address temp = array[i];
            array[i] = array[j];
            array[j] = temp;
        }
    }

    receive() external payable {}
}
