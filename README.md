# AdminOnly Contract

This Solidity contract, `AdminOnly`, is designed to manage the withdrawal of a shared treasure, with strict access control limited to an administrator (owner).

## Features

* **Owner-Controlled:** Only the contract owner can add treasure, approve withdrawals, revoke approvals, and transfer ownership.
* **Treasure Management:** The owner can add treasure to the contract.
* **Withdrawal Approvals:** The owner can approve specific amounts of treasure for designated recipients.
* **Withdrawal Revocation:** The owner can revoke previously granted withdrawal approvals.
* **One-Time Withdrawal:** Recipients can withdraw their approved amount only once.
* **Withdrawal Status Reset:** The owner can reset the withdrawal status of a recipient, allowing them to withdraw again.
* **Events:** The contract emits events for ownership transfers, treasure additions, withdrawal approvals, revocations, withdrawals, and withdrawal status resets.
* **View Functions:** The contract includes view functions to check the total treasure amount, withdrawal allowance for an address, and withdrawal status of an address.

## Getting Started

### Prerequisites

* **Solidity Compiler:** You'll need a Solidity compiler (e.g., `solc`) to compile the contract.
* **Ethereum Development Environment:** A development environment like Hardhat, Truffle, or Remix is recommended for deploying and interacting with the contract.
* **Ethereum Provider:** You'll need an Ethereum provider (e.g., MetaMask, Infura) to deploy the contract to a blockchain (local or testnet).

### Deployment

1.  **Compile the contract:** Use your chosen development environment to compile the `AdminOnly.sol` contract.  For example, using Hardhat:

    ```bash
    npx hardhat compile
    ```

2.  **Deploy the contract:** Deploy the compiled contract to your desired Ethereum network.  You'll need to configure your deployment script with the appropriate network settings and private key.  For example, using Hardhat:

    ```javascript
    // Example deployment script (deploy.js)
    const hre = require("hardhat");

    async function main() {
      const AdminOnly = await hre.ethers.getContractFactory("AdminOnly");
      const adminOnly = await AdminOnly.deploy();

      await adminOnly.deployed();

      console.log("AdminOnly deployed to:", adminOnly.address);
    }

    main().catch((error) => {
      console.error(error);
      process.exitCode = 1;
    });
    ```

    Then run:

    ```bash
    npx hardhat run scripts/deploy.js --network <network_name>
    ```

3.  **Interact with the contract:** Once deployed, you can interact with the contract using:

    * **Hardhat console:** For local testing.
    * **Etherscan:** For interacting with deployed contracts on public networks.
    * **Web3 libraries (Ethers.js, Web3.js):** For building custom scripts or front-end applications.

## Contract Details

### State Variables

* `owner`: (`address` public) The address of the contract owner (set during deployment).
* `treasureAmount`: (`uint256` public) The total amount of treasure in the contract.
* `allowedWithdrawals`: (`mapping(address => uint256)` public)  A mapping of addresses to their approved withdrawal amounts.
* `hasWithdrawn`: (`mapping(address => bool)` public) A mapping indicating whether an address has already withdrawn their allowance.

### Events

* `OwnershipTransferred(address indexed previousOwner, address indexed newOwner)`: Emitted when the contract ownership is transferred.
* `TreasureAdded(uint256 amount)`: Emitted when treasure is added to the contract.
* `WithdrawalApproved(address indexed recipient, uint256 amount)`: Emitted when a withdrawal is approved for a recipient.
* `WithdrawalRevoked(address indexed recipient)`: Emitted when a withdrawal approval is revoked.
* `TreasureWithdrawn(address indexed recipient, uint256 amount)`: Emitted when a recipient successfully withdraws treasure.
* `WithdrawalStatusReset(address indexed recipient)`: Emitted when the withdrawal status of a recipient is reset.

### Modifiers

* `onlyOwner`:  A modifier that restricts function access to the contract owner.

### Functions

* `constructor()`:  Initializes the contract, setting the deployer as the owner.
* `addTreasureAmount(uint256 amount)` (`public` `onlyOwner`): Adds treasure to the contract.
    * Requires `amount` to be greater than 0.
    * Emits `TreasureAdded` event.
* `approveTreasureWithdrawal(address recipient, uint256 amount)` (`public` `onlyOwner`): Approves a withdrawal for a recipient.
    * Requires `recipient` to be a valid address.
    * Requires `amount` to be greater than 0.
    * Requires `amount` to be less than or equal to the current `treasureAmount`.
    * Emits `WithdrawalApproved` event.
* `revokeTreasureWithdrawal(address recipient)` (`public` `onlyOwner`): Revokes a withdrawal approval.
    * Requires `recipient` to be a valid address.
    * Requires the recipient to have an existing allowance.
    * Emits `WithdrawalRevoked` event.
* `withdrawTreasure(uint256 amount)` (`public`):  Allows a recipient to withdraw their approved treasure.
    * Requires `amount` to be greater than 0.
    * Requires the recipient to have a withdrawal allowance.
    * Requires `amount` to be less than or equal to the recipient's allowance.
    * Requires the recipient not to have already withdrawn.
    * Requires there to be enough `treasureAmount` in the contract.
    * Updates `hasWithdrawn`, `treasureAmount`, and `allowedWithdrawals`.
    * Emits `TreasureWithdrawn` event.
* `resetWithdrawalStatus(address recipient)` (`public` `onlyOwner`): Resets the withdrawal status of a recipient.
    * Requires `recipient` to be a valid address.
    * Emits `WithdrawalStatusReset`
* `transferOwnership(address newOwner)` (`public` `onlyOwner`): Transfers ownership of the contract to a new address.
    * Requires `newOwner` to be a valid address.
    * Emits `OwnershipTransferred` event.
* `getTreasureAmount()` (`public` `view` `returns (uint256)`): Returns the current treasure amount.
* `getWithdrawalAllowance(address recipient)` (`public` `view` `returns (uint256)`): Returns the withdrawal allowance for a given address.
* `hasWithdrawnTreasure(address recipient)` (`public` `view` `returns (bool)`): Returns the withdrawal status for a given address.

## Security Considerations

* **Owner Privileges:** The contract relies heavily on the owner for managing treasure and withdrawals.  It's crucial to secure the owner's address.
* **One-Time Withdrawal:** The contract enforces a one-time withdrawal for each approved amount.
* **Re-entrancy:** The `withdrawTreasure` function modifies state variables before sending funds, which helps prevent re-entrancy attacks.  However, always follow secure coding practices.
* **Gas Limits:** Ensure that all functions, especially `withdrawTreasure`, have reasonable gas costs to prevent denial-of-service attacks.

## Usage Example

Here's a basic example of how to use the contract:

1.  **Deploy the contract.**
2.  **Owner adds treasure:** The owner calls `addTreasureAmount` to add funds to the contract.
3.  **Owner approves withdrawal:** The owner calls `approveTreasureWithdrawal` to allow a specific address to withdraw a certain amount.
4.  **Recipient withdraws:** The recipient calls `withdrawTreasure` to withdraw their approved amount.
5.  **Owner can revoke or reset:** If needed, the owner can call `revokeTreasureWithdrawal` to prevent a withdrawal or `resetWithdrawalStatus` to allow a withdrawal again.
