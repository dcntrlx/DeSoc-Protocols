// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract MultiOwnerWallet {

    address[] public owners;                 
    mapping(address => bool) public isOwner; 

    uint256 public withdrawalAmount;         
    address public withdrawalTo;             
    bool public withdrawalRequested;         

    mapping(address => bool) public approval; 
    uint256 public approvalCount;            

   
     constructor(address[] memory _owners) {
        require(_owners.length > 0, "Need at least 1 owner");

        for (uint256 i = 0; i < _owners.length; i++) {
            address owner = _owners[i];
            require(owner != address(0), "Invalid owner");
            require(!isOwner[owner], "Duplicate owner");

            owners.push(owner);
            isOwner[owner] = true;
        }
    }

    modifier onlyOwner() {
        require(isOwner[msg.sender], "Not an owner");
        _;
    }

    function deposit() external payable onlyOwner {}

    function requestWithdrawal(uint256 amount, address to)
        external
        onlyOwner
    {
        require(!withdrawalRequested, "Already requested");
        require(address(this).balance >= amount, "Not enough funds");

        withdrawalAmount = amount;
        withdrawalTo = to;
        withdrawalRequested = true;

        for (uint256 i = 0; i < owners.length; i++) {
            approval[owners[i]] = false;
        }
        approvalCount = 0;
    }

   
    function approveWithdrawal() external onlyOwner {
        require(withdrawalRequested, "No withdrawal requested");
        require(!approval[msg.sender], "Already approved");

        approval[msg.sender] = true;
        approvalCount++;

        if (approvalCount == owners.length) {
            payable(withdrawalTo).transfer(withdrawalAmount);

            withdrawalRequested = false;
            withdrawalAmount = 0;
            withdrawalTo = address(0);
        }
    }

    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getOwners() external view returns (address[] memory) {
    return owners;
}

}

