// Sources flattened with hardhat v2.22.18 https://hardhat.org

// SPDX-License-Identifier: MIT

// File @openzeppelin/contracts/utils/Context.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.1) (utils/Context.sol)

pragma solidity ^0.8.20;

/**
 * @dev Provides information about the current execution context, including the
 * sender of the transaction and its data. While these are generally available
 * via msg.sender and msg.data, they should not be accessed in such a direct
 * manner, since when dealing with meta-transactions the account sending and
 * paying for execution may not be the actual sender (as far as an application
 * is concerned).
 *
 * This contract is only required for intermediate, library-like contracts.
 */
abstract contract Context {
    function _msgSender() internal view virtual returns (address) {
        return msg.sender;
    }

    function _msgData() internal view virtual returns (bytes calldata) {
        return msg.data;
    }

    function _contextSuffixLength() internal view virtual returns (uint256) {
        return 0;
    }
}


// File @openzeppelin/contracts/access/Ownable.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.0.0) (access/Ownable.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module which provides a basic access control mechanism, where
 * there is an account (an owner) that can be granted exclusive access to
 * specific functions.
 *
 * The initial owner is set to the address provided by the deployer. This can
 * later be changed with {transferOwnership}.
 *
 * This module is used through inheritance. It will make available the modifier
 * `onlyOwner`, which can be applied to your functions to restrict their use to
 * the owner.
 */
abstract contract Ownable is Context {
    address private _owner;

    /**
     * @dev The caller account is not authorized to perform an operation.
     */
    error OwnableUnauthorizedAccount(address account);

    /**
     * @dev The owner is not a valid owner account. (eg. `address(0)`)
     */
    error OwnableInvalidOwner(address owner);

    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

    /**
     * @dev Initializes the contract setting the address provided by the deployer as the initial owner.
     */
    constructor(address initialOwner) {
        if (initialOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(initialOwner);
    }

    /**
     * @dev Throws if called by any account other than the owner.
     */
    modifier onlyOwner() {
        _checkOwner();
        _;
    }

    /**
     * @dev Returns the address of the current owner.
     */
    function owner() public view virtual returns (address) {
        return _owner;
    }

    /**
     * @dev Throws if the sender is not the owner.
     */
    function _checkOwner() internal view virtual {
        if (owner() != _msgSender()) {
            revert OwnableUnauthorizedAccount(_msgSender());
        }
    }

    /**
     * @dev Leaves the contract without owner. It will not be possible to call
     * `onlyOwner` functions. Can only be called by the current owner.
     *
     * NOTE: Renouncing ownership will leave the contract without an owner,
     * thereby disabling any functionality that is only available to the owner.
     */
    function renounceOwnership() public virtual onlyOwner {
        _transferOwnership(address(0));
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Can only be called by the current owner.
     */
    function transferOwnership(address newOwner) public virtual onlyOwner {
        if (newOwner == address(0)) {
            revert OwnableInvalidOwner(address(0));
        }
        _transferOwnership(newOwner);
    }

    /**
     * @dev Transfers ownership of the contract to a new account (`newOwner`).
     * Internal function without access restriction.
     */
    function _transferOwnership(address newOwner) internal virtual {
        address oldOwner = _owner;
        _owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }
}


// File @chainlink/contracts/src/v0.8/automation/interfaces/AutomationCompatibleInterface.sol@v1.3.0

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.0;

// solhint-disable-next-line interface-starts-with-i
interface AutomationCompatibleInterface {
  /**
   * @notice method that is simulated by the keepers to see if any work actually
   * needs to be performed. This method does does not actually need to be
   * executable, and since it is only ever simulated it can consume lots of gas.
   * @dev To ensure that it is never called, you may want to add the
   * cannotExecute modifier from KeeperBase to your implementation of this
   * method.
   * @param checkData specified in the upkeep registration so it is always the
   * same for a registered upkeep. This can easily be broken down into specific
   * arguments using `abi.decode`, so multiple upkeeps can be registered on the
   * same contract and easily differentiated by the contract.
   * @return upkeepNeeded boolean to indicate whether the keeper should call
   * performUpkeep or not.
   * @return performData bytes that the keeper should call performUpkeep with, if
   * upkeep is needed. If you would like to encode data to decode later, try
   * `abi.encode`.
   */
  function checkUpkeep(bytes calldata checkData) external returns (bool upkeepNeeded, bytes memory performData);

  /**
   * @notice method that is actually executed by the keepers, via the registry.
   * The data returned by the checkUpkeep simulation will be passed into
   * this method to actually be executed.
   * @dev The input to this method should not be trusted, and the caller of the
   * method should not even be restricted to any single registry. Anyone should
   * be able call it, and the input should be validated, there is no guarantee
   * that the data passed in is the performData returned from checkUpkeep. This
   * could happen due to malicious keepers, racing keepers, or simply a state
   * change while the performUpkeep transaction is waiting for confirmation.
   * Always validate the data passed in.
   * @param performData is the data which was passed back from the checkData
   * simulation. If it is encoded, it can easily be decoded into other types by
   * calling `abi.decode`. This data should not be trusted, and should be
   * validated against the contract's current state.
   */
  function performUpkeep(bytes calldata performData) external;
}


// File @openzeppelin/contracts/token/ERC20/IERC20.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (token/ERC20/IERC20.sol)

pragma solidity ^0.8.20;

/**
 * @dev Interface of the ERC-20 standard as defined in the ERC.
 */
interface IERC20 {
    /**
     * @dev Emitted when `value` tokens are moved from one account (`from`) to
     * another (`to`).
     *
     * Note that `value` may be zero.
     */
    event Transfer(address indexed from, address indexed to, uint256 value);

    /**
     * @dev Emitted when the allowance of a `spender` for an `owner` is set by
     * a call to {approve}. `value` is the new allowance.
     */
    event Approval(address indexed owner, address indexed spender, uint256 value);

    /**
     * @dev Returns the value of tokens in existence.
     */
    function totalSupply() external view returns (uint256);

    /**
     * @dev Returns the value of tokens owned by `account`.
     */
    function balanceOf(address account) external view returns (uint256);

    /**
     * @dev Moves a `value` amount of tokens from the caller's account to `to`.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transfer(address to, uint256 value) external returns (bool);

    /**
     * @dev Returns the remaining number of tokens that `spender` will be
     * allowed to spend on behalf of `owner` through {transferFrom}. This is
     * zero by default.
     *
     * This value changes when {approve} or {transferFrom} are called.
     */
    function allowance(address owner, address spender) external view returns (uint256);

    /**
     * @dev Sets a `value` amount of tokens as the allowance of `spender` over the
     * caller's tokens.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * IMPORTANT: Beware that changing an allowance with this method brings the risk
     * that someone may use both the old and the new allowance by unfortunate
     * transaction ordering. One possible solution to mitigate this race
     * condition is to first reduce the spender's allowance to 0 and set the
     * desired value afterwards:
     * https://github.com/ethereum/EIPs/issues/20#issuecomment-263524729
     *
     * Emits an {Approval} event.
     */
    function approve(address spender, uint256 value) external returns (bool);

    /**
     * @dev Moves a `value` amount of tokens from `from` to `to` using the
     * allowance mechanism. `value` is then deducted from the caller's
     * allowance.
     *
     * Returns a boolean value indicating whether the operation succeeded.
     *
     * Emits a {Transfer} event.
     */
    function transferFrom(address from, address to, uint256 value) external returns (bool);
}


// File @openzeppelin/contracts/utils/ReentrancyGuard.sol@v5.2.0

// Original license: SPDX_License_Identifier: MIT
// OpenZeppelin Contracts (last updated v5.1.0) (utils/ReentrancyGuard.sol)

pragma solidity ^0.8.20;

/**
 * @dev Contract module that helps prevent reentrant calls to a function.
 *
 * Inheriting from `ReentrancyGuard` will make the {nonReentrant} modifier
 * available, which can be applied to functions to make sure there are no nested
 * (reentrant) calls to them.
 *
 * Note that because there is a single `nonReentrant` guard, functions marked as
 * `nonReentrant` may not call one another. This can be worked around by making
 * those functions `private`, and then adding `external` `nonReentrant` entry
 * points to them.
 *
 * TIP: If EIP-1153 (transient storage) is available on the chain you're deploying at,
 * consider using {ReentrancyGuardTransient} instead.
 *
 * TIP: If you would like to learn more about reentrancy and alternative ways
 * to protect against it, check out our blog post
 * https://blog.openzeppelin.com/reentrancy-after-istanbul/[Reentrancy After Istanbul].
 */
abstract contract ReentrancyGuard {
    // Booleans are more expensive than uint256 or any type that takes up a full
    // word because each write operation emits an extra SLOAD to first read the
    // slot's contents, replace the bits taken up by the boolean, and then write
    // back. This is the compiler's defense against contract upgrades and
    // pointer aliasing, and it cannot be disabled.

    // The values being non-zero value makes deployment a bit more expensive,
    // but in exchange the refund on every call to nonReentrant will be lower in
    // amount. Since refunds are capped to a percentage of the total
    // transaction's gas, it is best to keep them low in cases like this one, to
    // increase the likelihood of the full refund coming into effect.
    uint256 private constant NOT_ENTERED = 1;
    uint256 private constant ENTERED = 2;

    uint256 private _status;

    /**
     * @dev Unauthorized reentrant call.
     */
    error ReentrancyGuardReentrantCall();

    constructor() {
        _status = NOT_ENTERED;
    }

    /**
     * @dev Prevents a contract from calling itself, directly or indirectly.
     * Calling a `nonReentrant` function from another `nonReentrant`
     * function is not supported. It is possible to prevent this from happening
     * by making the `nonReentrant` function external, and making it call a
     * `private` function that does the actual work.
     */
    modifier nonReentrant() {
        _nonReentrantBefore();
        _;
        _nonReentrantAfter();
    }

    function _nonReentrantBefore() private {
        // On the first call to nonReentrant, _status will be NOT_ENTERED
        if (_status == ENTERED) {
            revert ReentrancyGuardReentrantCall();
        }

        // Any calls to nonReentrant after this point will fail
        _status = ENTERED;
    }

    function _nonReentrantAfter() private {
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _status = NOT_ENTERED;
    }

    /**
     * @dev Returns true if the reentrancy guard is currently set to "entered", which indicates there is a
     * `nonReentrant` function in the call stack.
     */
    function _reentrancyGuardEntered() internal view returns (bool) {
        return _status == ENTERED;
    }
}


// File contracts/AutoSendAssets.sol

// Original license: SPDX_License_Identifier: MIT
pragma solidity ^0.8.20;
contract AutoSendAssets is AutomationCompatibleInterface, ReentrancyGuard, Ownable {
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

    // Admin
    function updatePlatformWallet(address _platformWallet) external onlyOwner {
        require(_platformWallet != address(0), "Invalid platform wallet");
        platformWallet = _platformWallet;
    }

    function updateFee(uint256 _newFee) external onlyOwner {
        require(_newFee >= 5, "Invalid fee");
        FEE_PERCENTAGE = _newFee;
    }

    // Protocol
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

        emit StateUpdated(msg.sender, recipient, description, asset, amount, interval, block.timestamp, expiredTime, State.Updated, block.timestamp);
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

        emit StateUpdated(sender, schedule.recipient, schedule.description, schedule.asset, schedule.amount, schedule.interval, block.timestamp, schedule.expiredTime, State.Funded, block.timestamp);
    }

    function getSchedules() external view returns (Schedule[] memory) {
        return schedules[msg.sender];
    }

    function getUsers() external view onlyOwner returns (address[] memory) {
        return users;
    }
}