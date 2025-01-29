// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/KeeperCompatibleInterface.sol";

contract AutoSendAssets is KeeperCompatibleInterface {
    address public platformWallet; // Wallet to receive the 0.5% fee

    enum State {
        Scheduled,
        Updated,
        Canceled,
        Funded,
        Expired
    }

    struct Schedule {
        string description;  // Description of the schedule
        address asset;       // Asset to send
        address recipient;   // Recipient of the funds
        uint256 amount;      // Amount to send
        uint256 interval;    // Timestamp to send
        uint256 lastExecutedTime; // Last execution timestamp
        uint256 expiredTime;  // Expiration timestamp
        State state;        // Current state of the schedule
    }

    address[] public users; // List of users
    mapping(address => bool) public isUser; // Tracks user existence

    mapping(address => Schedule[]) public schedules; // Tracks user schedules

    event StateUpdated(string description, address asset, address recipient, uint256 amount, uint256 interval, uint256 lastExecutedTime, uint256 expiredTime, State state, uint256 time);

    constructor(address _platformWallet) {
        platformWallet = _platformWallet;
    }

    modifier isValid(
        string memory description,
        address asset,
        address recipient,
        uint256 amount,
        uint256 interval,
        uint256 expiredTime
    ) {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(amount > 0, "Amount must be greater than zero");
        require(recipient != address(0), "Recipient address cannot be zero");
        require(interval >= 1 days, "Interval is not correct");
        require(expiredTime >= block.timestamp, "Expired time is not correct");

        try IERC20(asset).totalSupply() returns (uint256) {
            _;
        } catch {
            revert("Account must be ERC20 contract");
        }
    }

    // Create a new schedule for autosend
    function createSchedule(
        string memory description,
        address asset,
        address recipient,
        uint256 amount,
        uint256 interval,
        uint256 expiredTime
    ) external isValid(description, asset, recipient, amount, interval, expiredTime) {
        if (isUser[msg.sender] == false) {
            users.push(msg.sender);
            isUser[msg.sender] = true;
        }

        Schedule[] storage scheduleList = schedules[msg.sender];

        scheduleList.push(Schedule({
            description: description,
            asset: asset,
            recipient: recipient,
            amount: amount,
            interval: interval,
            expiredTime: expiredTime,
            lastExecutedTime: 0,
            state: State.Scheduled
        }));

        emit StateUpdated(description, asset, recipient, amount, interval, 0, expiredTime, State.Scheduled, block.timestamp);
    }

    // Modify an existing schedule
    function updateSchedule(
        uint256 index,
        address newAsset,
        uint256 newAmount,
        uint256 interval
    ) external {
        Schedule[] storage scheduleList = schedules[msg.sender];
        require(scheduleList[index].recipient != address(0), "Schedule does not exist");

        scheduleList[index].asset = newAsset;
        scheduleList[index].amount = newAmount;
        scheduleList[index].interval = interval;
        scheduleList[index].state = State.Updated;

        emit StateUpdated(scheduleList[index].description, newAsset, scheduleList[index].recipient, newAmount, interval, scheduleList[index].lastExecutedTime, scheduleList[index].expiredTime, State.Updated, block.timestamp);
    }

    // Cancel an existing schedule
    function cancelSchedule(uint256 index) external {
        Schedule[] storage scheduleList = schedules[msg.sender];
        require(scheduleList[index].recipient != address(0), "Schedule does not exist");

        scheduleList[index].state = State.Canceled;

        emit StateUpdated(scheduleList[index].description, scheduleList[index].asset, scheduleList[index].recipient, scheduleList[index].amount, scheduleList[index].interval, scheduleList[index].lastExecutedTime, scheduleList[index].expiredTime, State.Canceled, block.timestamp);
    }

    // Chainlink Keeper: Check if any schedules need to be executed
    function checkUpkeep(bytes calldata)
        external
        view
        override
        returns (bool upkeepNeeded, bytes memory performData)
    {
        upkeepNeeded = false;

        // Loop through all user schedules to check if upkeep is needed
        for (uint256 i = 0; i < users.length; i++) {
            Schedule[] memory scheduleList = schedules[users[i]];
            for (uint256 index = 0; index < scheduleList.length; index++) {
                if (scheduleList[index].state != State.Canceled && block.timestamp >= scheduleList[index].lastExecutedTime + scheduleList[index].interval) {
                    upkeepNeeded = true;
                    performData = abi.encode(users[i], index); // Pass the user as performData
                    break;
                }
            }
        }
    }

    // Chainlink Keeper: Perform upkeep
    function performUpkeep(bytes calldata performData) external override {
        (address sender, uint256 index) = abi.decode(performData, (address, uint256));
        Schedule[] storage scheduleList = schedules[sender];
        Schedule storage schedule = scheduleList[index];

        require(
            block.timestamp >= schedule.lastExecutedTime + schedule.interval,
            "Too soon to execute"
        );
        require(
            schedule.state != State.Canceled,
            "Schedule is canceled"
        );

        if (block.timestamp >= schedule.expiredTime) {
            schedule.state = State.Expired;

            emit StateUpdated(schedule.description, schedule.asset, schedule.recipient, schedule.amount, schedule.interval, schedule.lastExecutedTime, schedule.expiredTime, State.Expired, block.timestamp);
        }

        uint256 totalAmount = schedule.amount;
        uint256 fee = (totalAmount * 5) / 1000; // 0.5% fee

        uint256 totalWithFees = totalAmount + fee;

        IERC20 asset = IERC20(schedule.asset);

        // Check if sender has sufficient balance
        require(asset.balanceOf(sender) >= totalWithFees, "Insufficient balance");

        // Transfer funds to recipient
        require(
            asset.transferFrom(sender, schedule.recipient, schedule.amount),
            "Transfer to recipient failed"
        );

        // Transfer fee to platform wallet
        require(
            asset.transferFrom(sender, platformWallet, fee),
            "Transfer of fee failed"
        );

        // Update last executed time
        schedule.lastExecutedTime = block.timestamp;

        emit StateUpdated(schedule.description, schedule.asset, schedule.recipient, schedule.amount, schedule.interval, block.timestamp, schedule.expiredTime, State.Funded, block.timestamp);
    }

    // View details of a user's schedule
    function getSchedule(address user)
        external
        view
        returns (Schedule[] memory)
    {
        Schedule[] memory scheduleList = schedules[user];
        return scheduleList;
    }
}
