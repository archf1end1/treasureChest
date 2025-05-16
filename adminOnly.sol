//SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

/**
 * @title AdminOnly
 * @dev Contract for managing treasure withdrawals with admin controls
 */
contract AdminOnly {
    // State variables
    address public owner;
    uint256 public treasureAmount;
    mapping(address => uint256) public allowedWithdrawals;
    mapping(address => bool) public hasWithdrawn;

    // Events
    event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);
    event TreasureAdded(uint256 amount);
    event WithdrawalApproved(address indexed recipient, uint256 amount);
    event WithdrawalRevoked(address indexed recipient);
    event TreasureWithdrawn(address indexed recipient, uint256 amount);
    event WithdrawalStatusReset(address indexed recipient);

    constructor() {
        owner = msg.sender;
        emit OwnershipTransferred(address(0), msg.sender);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    /**
     * @dev Adds treasure to the contract
     * @param amount Amount of treasure to add
     */
    function addTreasureAmount(uint256 amount) public onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        treasureAmount += amount;
        emit TreasureAdded(amount);
    }

    /**
     * @dev Approves treasure withdrawal for a recipient
     * @param recipient Address to approve withdrawal for
     * @param amount Amount to approve
     */
    function approveTreasureWithdrawal(address recipient, uint256 amount) public onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        require(amount > 0, "Amount must be greater than 0");
        require(amount <= treasureAmount, "Insufficient treasure amount");
        allowedWithdrawals[recipient] += amount;
        emit WithdrawalApproved(recipient, amount);
    }

    /**
     * @dev Revokes treasure withdrawal approval for a recipient
     * @param recipient Address to revoke approval for
     */
    function revokeTreasureWithdrawal(address recipient) public onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        uint256 amount = allowedWithdrawals[recipient];
        require(amount > 0, "No withdrawal allowance to revoke");
        allowedWithdrawals[recipient] = 0;
        emit WithdrawalRevoked(recipient);
    }

    /**
     * @dev Withdraws approved treasure amount
     * @param amount Amount to withdraw
     */
    function withdrawTreasure(uint256 amount) public {
        require(amount > 0, "Amount must be greater than 0");
        uint256 allowance = allowedWithdrawals[msg.sender];
        require(allowance > 0, "No treasure allowance");
        require(allowance >= amount, "Amount exceeds allowance");
        require(!hasWithdrawn[msg.sender], "Already withdrawn");
        require(amount <= treasureAmount, "Insufficient treasure amount");

        hasWithdrawn[msg.sender] = true;
        treasureAmount -= amount;
        allowedWithdrawals[msg.sender] = 0;

        emit TreasureWithdrawn(msg.sender, amount);
    }

    /**
     * @dev Resets withdrawal status for a recipient
     * @param recipient Address to reset status for
     */
    function resetWithdrawalStatus(address recipient) public onlyOwner {
        require(recipient != address(0), "Invalid recipient address");
        hasWithdrawn[recipient] = false;
        emit WithdrawalStatusReset(recipient);
    }

    /**
     * @dev Transfers ownership of the contract
     * @param newOwner Address of the new owner
     */
    function transferOwnership(address newOwner) public onlyOwner {
        require(newOwner != address(0), "Invalid new owner address");
        address oldOwner = owner;
        owner = newOwner;
        emit OwnershipTransferred(oldOwner, newOwner);
    }

    /**
     * @dev Returns the current treasure amount
     * @return uint256 Current treasure amount
     */
    function getTreasureAmount() public view returns (uint256) {
        return treasureAmount;
    }

    /**
     * @dev Returns the withdrawal allowance for an address
     * @param recipient Address to check
     * @return uint256 Withdrawal allowance
     */
    function getWithdrawalAllowance(address recipient) public view returns (uint256) {
        return allowedWithdrawals[recipient];
    }

    /**
     * @dev Returns whether an address has withdrawn
     * @param recipient Address to check
     * @return bool Whether the address has withdrawn
     */
    function hasWithdrawnTreasure(address recipient) public view returns (bool) {
        return hasWithdrawn[recipient];
    }
}