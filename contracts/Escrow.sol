// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "hardhat/console.sol";

contract Escrow {
    struct Contract {
        address Arbiter;
        address payable Beneficiary;
        address payable Depositor;
        uint256 timestamp;
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
        uint256 timestamp,
        uint256 amount,
        bool arbApprove,
        bool isApprove,
        bool dismiss
    );

    function approve(uint256 i) external {
        require(!contracts[i].IsApproved, "contract has been already approved");
        require(
            contracts[i].ArbiterApproved,
            "the arbiter is not approved from beneficiary yet"
        );
        require(
            msg.sender == contracts[i].Arbiter,
            "you are not the contracts's arbiter"
        );
        uint256 balance = contracts[i].Amount;
        (bool success, ) = contracts[i].Beneficiary.call{value: balance}("");
        contracts[i].IsApproved = true;
        console.log("escrow between parties has been approved from arbiter");
    }

    function approveArbiter(uint256 i) external {
        require(
            msg.sender == contracts[i].Beneficiary,
            "you are not the escrow's beneficiary"
        );
        contracts[i].ArbiterApproved = true;
        console.log("arbiter has been approved from beneficiary too");
    }

    function getAllContracts() external view returns (Contract[] memory) {
        return contracts;
    }

    function dismissEscrow(uint256 i) external {
        require(
            !contracts[i].Dismissed,
            "this escrow has been already dismissed"
        );
        require(
            !contracts[i].IsApproved,
            "this escrow has been approved you can't dismiss it"
        );
        require(
            msg.sender == contracts[i].Arbiter,
            "you are not the escrow's arbiter"
        );
        uint256 balance = contracts[i].Amount;
        (bool success, ) = contracts[i].Depositor.call{value: balance}("");
        contracts[i].Dismissed = true;
        delete contracts[i];
        console.log("escrow dismissed");
    }

    function deleteContract(uint256 i) external {
        require(contracts[i].IsApproved);
        require(
            msg.sender == contracts[i].Depositor ||
                msg.sender == contracts[i].Beneficiary
        );
        delete contracts[i];
    }

    function writeNewContract(address _arbiter, address payable _beneficiary)
        external
        payable
    {
        require(msg.value > 0, "insert the value of your escrow");

        contracts.push(
            Contract(
                _arbiter,
                _beneficiary,
                payable(msg.sender),
                block.timestamp,
                msg.value,
                false,
                false,
                false
            )
        );
        emit NewContract(
            _arbiter,
            _beneficiary,
            msg.sender,
            block.timestamp,
            msg.value,
            false,
            false,
            false
        );
        console.log("a new contract has been written");
    }
}
