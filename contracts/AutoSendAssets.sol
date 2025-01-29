// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@chainlink/contracts/src/v0.8/automation/interfaces/KeeperCompatibleInterface.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract AutoSendAssets is KeeperCompatibleInterface, ReentrancyGuard, Ownable {
    address public platformWallet; // Wallet to receive the 0.5% fee
    uint256 public FEE_PERCENTAGE = 5; // 0.5% fee

    enum State {
        Scheduled,
        Updated,
        Canceled,
        Funded,
        Expired
    }

    struct Schedule {
        address sender;      // Sender of the funds
        string description;  // Description of the schedule
        address asset;       // Asset to send
        address recipient;   // Recipient of the funds
        uint256 amount;      // Amount to send
        uint256 interval;    // Time interval for sending funds
        uint256 lastExecutedTime; // Last execution timestamp
        uint256 expiredTime;  // Expiration timestamp
        State state;         // Current state of the schedule
    }

    address[] private users; // List of users
    mapping(address => Schedule[]) private schedules; // User schedules

    event StateUpdated(address indexed user, address indexed recipient, string description, address asset, uint256 amount, uint256 interval, uint256 lastExecutedTime, uint256 expiredTime, State indexed state, uint256 blockTime);

    constructor(address _platformWallet) Ownable(msg.sender) {
        require(_platformWallet != address(0), "Invalid platform wallet");
        platformWallet = _platformWallet;
    }

    modifier onlyValidSchedule(address sender, uint256 index) {
        require(index < schedules[sender].length, "Schedule does not exist");
        require(schedules[sender][index].state != State.Expired, "Schedule was expired");
        require(schedules[sender][index].state != State.Canceled, "Schedule was canceled");
        _;
    }

    // admin
    function updatePlatformWallet(address _platformWallet) external onlyOwner {
        require(_platformWallet != address(0), "Invalid platform wallet");
        platformWallet = _platformWallet;
    }

    function updateFee(uint256 _newFee) external onlyOwner {
        require(_newFee > 5, "Invalid fee");
        FEE_PERCENTAGE = _newFee;
    }

    function isUser(address user) internal view returns (bool) {
        for (uint256 i = 0; i < users.length; i++) {
            if (users[i] == user) return true;
        }
        return false;
    }

    function createSchedule(
        string memory description,
        address asset,
        address recipient,
        uint256 amount,
        uint256 interval,
        uint256 expiredTime
    ) external {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(asset != address(0), "Asset cannot be zero address");
        require(recipient != address(0), "Recipient cannot be zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(interval >= 1 days, "Interval must be at least one day");
        require(expiredTime > block.timestamp, "Expiration must be in the future");

        schedules[msg.sender].push(Schedule({
            sender: msg.sender,
            description: description,
            asset: asset,
            recipient: recipient,
            amount: amount,
            interval: interval,
            lastExecutedTime: block.timestamp,
            expiredTime: expiredTime,
            state: State.Scheduled
        }));

        if (!isUser(msg.sender)) {
            users.push(msg.sender); // Track new user if not already present
        }

        emit StateUpdated(msg.sender, recipient, description, asset, amount, interval, block.timestamp, expiredTime, State.Scheduled, block.timestamp);
    }

    function updateSchedule(
        uint256 index,
        string memory description,
        address asset,
        address recipient,
        uint256 amount,
        uint256 interval,
        uint256 expiredTime
    ) external onlyValidSchedule(msg.sender, index) {
        require(bytes(description).length > 0, "Description cannot be empty");
        require(asset != address(0), "Asset cannot be zero address");
        require(recipient != address(0), "Recipient cannot be zero address");
        require(amount > 0, "Amount must be greater than zero");
        require(interval >= 1 days, "Interval must be at least one day");
        require(expiredTime > block.timestamp, "Expiration must be in the future");

        Schedule storage schedule = schedules[msg.sender][index];

        schedule.description = description;
        schedule.asset = asset;
        schedule.recipient = recipient;
        schedule.amount = amount;
        schedule.interval = interval;
        schedule.expiredTime = expiredTime;
        schedule.state = State.Updated;
        schedule.lastExecutedTime = block.timestamp;

        if (!isUser(msg.sender)) {
            users.push(msg.sender); // Track new user if not already present
        }

        emit StateUpdated(msg.sender, recipient, description, asset, amount, interval, block.timestamp, expiredTime, State.Scheduled, block.timestamp);
    }

    function cancelSchedule(uint256 index) external onlyValidSchedule(msg.sender, index) {
        schedules[msg.sender][index].state = State.Canceled;
        emit StateUpdated(msg.sender, schedules[msg.sender][index].recipient, schedules[msg.sender][index].description, schedules[msg.sender][index].asset, schedules[msg.sender][index].amount, schedules[msg.sender][index].interval, schedules[msg.sender][index].lastExecutedTime, schedules[msg.sender][index].expiredTime, State.Canceled, block.timestamp);
    }

    function checkUpkeep(bytes calldata) external view override returns (bool upkeepNeeded, bytes memory performData) {
        for (uint256 i = 0; i < users.length; i++) {
            Schedule[] memory userSchedules = schedules[users[i]];
            for (uint256 j = 0; j < userSchedules.length; j++) {
                if (userSchedules[j].state != State.Expired && userSchedules[j].state != State.Canceled && block.timestamp >= userSchedules[j].lastExecutedTime + userSchedules[j].interval) {
                    upkeepNeeded = true;
                    performData = abi.encode(users[i], j); // Pass user and index for execution
                    return (upkeepNeeded, performData);
                }
            }
        }
    }

    function performUpkeep(bytes calldata performData) external override nonReentrant {
        (address sender, uint256 index) = abi.decode(performData, (address, uint256));
        
        require(sender != address(0), "Invalid sender");

        executeSchedule(sender, index); // Call the internal function to execute the schedule
    }

    function executeSchedule(address sender, uint256 index) internal nonReentrant onlyValidSchedule(sender, index) {
        Schedule storage schedule = schedules[sender][index];

        require(block.timestamp >= schedule.lastExecutedTime + schedule.interval, "Too soon to execute");

        require(schedule.state != State.Canceled, "Schedule was canceled");

        require(schedule.state != State.Expired, "Schedule was expired");

        if (block.timestamp >= schedule.expiredTime) {
            schedule.state = State.Expired;
            emit StateUpdated(sender, schedule.recipient, schedule.description, schedule.asset, schedule.amount, schedule.interval, schedule.lastExecutedTime, schedule.expiredTime, State.Expired, block.timestamp);
            return;
        }

        uint256 fee = (schedule.amount * FEE_PERCENTAGE) / 1000; // Calculate fee
        uint256 totalAmount = schedule.amount + fee;

        IERC20 asset = IERC20(schedule.asset);
        
        require(asset.balanceOf(sender) >= totalAmount, "Insufficient balance");

        // Transfer funds to recipient and fee to platform wallet in a single transaction.
        asset.transferFrom(sender, schedule.recipient, schedule.amount);
        asset.transferFrom(sender, platformWallet, fee);

        schedule.lastExecutedTime = block.timestamp;

        emit StateUpdated(sender, schedule.recipient, schedule.description, schedule.asset, schedule.amount, schedule.interval, block.timestamp, schedule.expiredTime, State.Expired, block.timestamp);
    }

    function getSchedules() external view returns (Schedule[] memory) {
        return schedules[msg.sender];
    }
}
