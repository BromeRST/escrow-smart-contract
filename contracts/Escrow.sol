// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract Escrow {
    address public arbiter;
    address payable public beneficiary;
    address payable public depositor;
    address payable public owner;

    struct Contract {
        address Arbiter;
        address payable Beneficiary;
        address payable Depositor;
        uint256 Amount;
        bool ArbiterApproved;
        bool IsApproved;
        bool Dismissed;
    }

    Contract[] contracts;

    event NewContract(
        address indexed arb,
        address indexed ben,
        address indexed dep,
        uint256 amount,
        bool arbApprove,
        bool isApprove,
        bool dismiss
    );

    constructor() {
        owner = payable(msg.sender);
    }

    function approve(uint256 i) external {
        require(contracts[i].ArbiterApproved);
        require(msg.sender == contracts[i].Arbiter);
        uint256 balance = contracts[i].Amount;
        (bool success, ) = contracts[i].Beneficiary.call{value: balance}("");
        contracts[i].IsApproved = true;
        console.log("escrow between parties has been approved from arbiter");
    }

    function approveArbiter(uint256 i) external {
        require(msg.sender == contracts[i].Beneficiary);
        contracts[i].ArbiterApproved = true;
        console.log("arbiter has been approved from beneficiary too");
    }

    function getAllContracts() external view returns (Contract[] memory) {
        return contracts;
    }

    function dismissEscrow(uint256 i) external {
        require(!contracts[i].Dismissed);
        require(
            msg.sender == contracts[i].Depositor ||
                msg.sender == contracts[i].Beneficiary ||
                msg.sender == contracts[i].Arbiter
        );
        uint256 balance = contracts[i].Amount;
        (bool success, ) = contracts[i].Depositor.call{value: balance}("");
        contracts[i].Dismissed = true;
        delete contracts[i];
        console.log("contract dismissed from depositor");
    }

    function writeNewContract(address _arbiter, address payable _beneficiary)
        external
        payable
    {
        require(msg.value > 0);
        arbiter = _arbiter;
        beneficiary = _beneficiary;
        depositor = payable(msg.sender);
        contracts.push(
            Contract(
                arbiter,
                beneficiary,
                depositor,
                msg.value,
                false,
                false,
                false
            )
        );
        emit NewContract(
            arbiter,
            beneficiary,
            depositor,
            msg.value,
            false,
            false,
            false
        );
        console.log("a new contract has been written");
    }
}
