// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @dev Only owner can start a withdrawal
contract MultiOwnerWallet {
    address[] public owners; // list of multisig wallet owners
    mapping(address => bool) public isOwner;

    uint256 public withdrawalAmount;

    uint32 public approvalThreshold;
    uint32 public approvalCount;

    address public withdrawalTo;
    bool public withdrawalRequested;

    mapping(uint256 => mapping(address => bool)) public approvals;
    uint256 public withdrawalId;

    constructor(address[] memory _owners, uint32 _approvalThreshold) {
        require(_owners.length > 0, "Need at least 1 owner");
        require(_approvalThreshold > 0, "Need at least 1 approval");
        require(_approvalThreshold <= _owners.length, "Approval threshold too high");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner"); // It s forbidden for one of the owners to be the zero address
            require(!isOwner[owner], "Duplicate owner"); // Its forbidden to have duplicate owners
            owners.push(owner);
            isOwner[owner] = true;
        }

        approvalThreshold = _approvalThreshold;
    }

    /// @notice Modifier to check if the caller one of the owners
    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    /// @notice Function to deposit funds to wallet
    function deposit() external payable {} // We let everyone deposit funds to wallet

    /// @notice Function to request withdrawal
    function requestWithdrawal(uint256 amount, address to) external onlyOwner {
        require(!withdrawalRequested, "Already requested");
        require(address(this).balance >= amount, "Not enough funds");

        withdrawalAmount = amount;
        withdrawalTo = to;
        withdrawalRequested = true;

        withdrawalId++;
        approvalCount = 0;
    }

    /// @notice Function to approve withdrawal
    function approveWithdrawal() external onlyOwner {
        require(withdrawalRequested, "No withdrawal requested");
        require(!approvals[withdrawalId][msg.sender], "Already approved");

        approvals[withdrawalId][msg.sender] = true;
        approvalCount++;

        if (approvalCount >= approvalThreshold) {
            payable(withdrawalTo).call{value: withdrawalAmount}(""); // Using safemethods for transfers

            withdrawalRequested = false;
            withdrawalAmount = 0;
            withdrawalTo = address(0);
        }
    }

    /// @notice Returns the balance of the multisigwallet
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    /// @notice Returns the list of owners
    function getOwners() external view returns (address[] memory) {
        return owners;
    }
}

