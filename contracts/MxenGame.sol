// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MxenGame is Ownable {
    struct Bid {
        address bidder;
        uint256 amount;
    }

    Bid[] public bids;

    uint256 public startTime;
    uint256 public endTime;
    address public highestBidder;
    uint256 public highestBid;

    IERC20 public mxenToken;
    uint256 public gameDuration; // Duration in seconds

    enum GameStatus {
        Inactive,
        Active,
        Ended
    }
    GameStatus public gameStatus;

    event BidPlaced(address indexed bidder, uint256 amount);
    event GameEnded();

    modifier gameIsActive() {
        require(gameStatus == GameStatus.Active, "Game is not active");
        require(
            block.timestamp >= startTime && block.timestamp <= endTime,
            "Outside game duration"
        );
        _;
    }

    modifier onlyAfterGameEnded() {
        require(gameStatus == GameStatus.Ended, "Game is still active");
        _;
    }

    constructor(address _mxenToken, uint256 _gameDurationInSeconds) {
        require(
            _gameDurationInSeconds > 0,
            "Game duration must be greater than zero"
        );
        mxenToken = IERC20(_mxenToken);
        gameDuration = _gameDurationInSeconds;
        gameStatus = GameStatus.Inactive;
    }

    function startGame() external onlyOwner {
        require(gameStatus == GameStatus.Inactive, "Game has already started");
        startTime = block.timestamp;
        endTime = startTime + gameDuration;
        gameStatus = GameStatus.Active;
    }

    function placeBid(uint256 amount) external gameIsActive {
        require(amount % 5000 == 0, "Bids must be in batches of 5,000");
        require(
            amount > highestBid,
            "Your bid must be higher than the current highest bid"
        );
        require(
            mxenToken.transferFrom(
                msg.sender,
                address(this),
                amount * 10 ** 18
            ),
            "Transfer failed"
        );

        bids.push(Bid({bidder: msg.sender, amount: amount}));

        highestBidder = msg.sender;
        highestBid = amount;

        emit BidPlaced(msg.sender, amount);
    }

    function claimReward() external onlyAfterGameEnded {
        require(
            msg.sender == highestBidder,
            "Only the highest bidder can claim"
        );

        uint256 rewardAmount = (mxenToken.balanceOf(address(this)) * 80) / 100;
        require(
            mxenToken.transfer(highestBidder, rewardAmount),
            "Transfer failed"
        );
        require(
            mxenToken.transfer(
                owner(),
                mxenToken.balanceOf(address(this)) - rewardAmount
            ),
            "Transfer failed"
        );

        highestBidder = address(0);
        highestBid = 0;
    }

    function endGame() external onlyOwner {
        require(gameStatus == GameStatus.Active, "Game is not active");
        gameStatus = GameStatus.Ended;
        emit GameEnded();
    }

    function withdrawTokens(
        address to,
        uint256 amount
    ) external onlyOwner onlyAfterGameEnded {
        require(mxenToken.transfer(to, amount), "Transfer failed");
    }

    function getTimeLeft() public view returns (uint256) {
        require(block.timestamp <= endTime, "Game has been ended already");
        uint256 timeLeft = endTime - block.timestamp;

        return timeLeft;
    }

    function getMxenInPool() public view returns (uint256) {
        return mxenToken.balanceOf(address(this));
    }

    function getBiddingHistory()
        public
        view
        returns (address[] memory, uint256[] memory)
    {
        uint256 historyLength = bids.length;
        address[] memory bidders = new address[](historyLength);
        uint256[] memory bidAmounts = new uint256[](historyLength);

        for (uint256 i = 0; i < historyLength; i++) {
            bidders[i] = bids[i].bidder;
            bidAmounts[i] = bids[i].amount;
        }

        return (bidders, bidAmounts);
    }
}
