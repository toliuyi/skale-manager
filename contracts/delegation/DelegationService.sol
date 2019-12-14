/*
    DelegationService.sol - SKALE Manager
    Copyright (C) 2019-Present SKALE Labs
    @author Dmytro Stebaiev

    SKALE Manager is free software: you can redistribute it and/or modify
    it under the terms of the GNU Affero General Public License as published
    by the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    SKALE Manager is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU Affero General Public License for more details.

    You should have received a copy of the GNU Affero General Public License
    along with SKALE Manager.  If not, see <https://www.gnu.org/licenses/>.
*/

pragma solidity ^0.5.3;
pragma experimental ABIEncoderV2;

import "../Permissions.sol";
import "../interfaces/delegation/IHolderDelegation.sol";
import "../interfaces/delegation/IValidatorDelegation.sol";
import "./DelegationRequestManager.sol";
import "./ValidatorService.sol";
import "./DelegationController.sol";


/**
*   @title Delegation Service Contract
*   @notice Implements IHolderDelegation and IValidatorDelegation interfaces
*/
contract DelegationService is Permissions, IHolderDelegation, IValidatorDelegation {

    event DelegationRequestIsSent(
        uint requestId
    );

    event ValidatorRegistered(
        uint validatorId
    );

    /**
        @notice constructor of DelegationService
        @param newContractsAddress to register for Permissions
    */
    constructor(address newContractsAddress) Permissions(newContractsAddress) public {

    }

    function requestUndelegation(uint delegationId) external {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.accept}
        calls DelegationRequestManager.acceptRequest
    */
    function accept(uint requestId) external {
        DelegationRequestManager delegationRequestManager = DelegationRequestManager(
            contractManager.getContract("DelegationRequestManager")
        );
        delegationRequestManager.acceptRequest(requestId);
    }

    /**
         @dev See {IValidatorDelegation-createNode}. Not Implemented!
    */
    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp) external
    {
        revert("Not implemented");
    }

    /**
       @dev See {IValidatorDelegation-minimumDelegationAmount}. Not Implemented!
    */
    function setMinimumDelegationAmount(uint amount) external {
        revert("Not implemented");
    }

    /**
       @dev "No interface" and "Not implemented"
       @notice Requests return of tokens that are locked in SkaleManager
    */
    function returnTokens(uint amount) external {
        revert("Not implemented");
    }

     /**
       @dev "No interface" and "Not implemented"
       @notice Allows service to slash `validator` by `amount` of tokens
    */
    function slash(address validator, uint amount) external {
        revert("Not implemented");
    }

    /**
        @dev "No interface" and "Not implemented"
        @notice Allows service to pay `amount` of tokens to `validator`
    */
    function pay(address validator, uint amount) external {
        revert("Not implemented");
    }

    /**
        @dev "No interface" and "Not implemented"
        @notice Returns amount of delegated token of the validator
        @param validator address of the validator
        @return amount of Delegated Tokens
    */
    function getDelegatedAmount(address validator) external returns (uint) {
        revert("Not implemented");
    }

    /**
        @dev "No interface" and "Not implemented"
        @notice Minimum Staking Requirement, set by the validator
        @param amount minimum staking amount
        @return Amount of Delegated Tokens
    */
    function setMinimumStakingRequirement(uint amount) external {
        revert("Not implemented");
    }

    /**
        @dev See {IHolderDelegation.delegate}
    */
    function delegate(
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    )
        external
    {
        DelegationRequestManager delegationRequestManager = DelegationRequestManager(
            contractManager.getContract("DelegationRequestManager")
        );
        uint requestId = delegationRequestManager.createRequest(
            msg.sender,
            validatorId,
            amount,
            delegationPeriod,
            info
        );
        emit DelegationRequestIsSent(requestId);
    }

    /**
        @dev See {IHolderDelegation.cancelPendingDelegation}
    */
    function cancelPendingDelegation(uint requestId) external {
        DelegationRequestManager delegationRequestManager = DelegationRequestManager(
            contractManager.getContract("DelegationRequestManager")
        );
        delegationRequestManager.cancelRequest(requestId);
    }

    /**
        @dev See {IHolderDelegation.getAllDelegationRequests}. "Not implemented"
    */
    function getAllDelegationRequests() external returns(uint[] memory) {
        revert("Not implemented");
    }

    /**
        @dev See {IHolderDelegation.getDelegationRequestsForValidator}. "Not implemented"
    */
    function getDelegationRequestsForValidator(uint validatorId) external returns (uint[] memory) {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.registerValidator}.
    */
    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRate,
        uint minimumDelegationAmount
    )
        external returns (uint validatorId)
    {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        validatorId = validatorService.registerValidator(
            name,
            description,
            feeRate,
            minimumDelegationAmount
        );
        emit ValidatorRegistered(validatorId);
    }

    /**
        @dev See {IValidatorDelegation.unregisterValidator}. "Not implemented"
    */
    function unregisterValidator(uint validatorId) external {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.getBondAmount}. "Not implemented"
    */
    function getBondAmount(uint validatorId) external returns (uint amount) {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.setValidatorName}. "Not implemented"
    */
    function setValidatorName(string calldata newName) external {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.setValidatorDescription}. "Not implemented"
    */
    function setValidatorDescription(string calldata descripton) external {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.setValidatorAddress}. "Not implemented"
    */
    function setValidatorAddress(address newAddress) external {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.getValidatorInfo}. "Not implemented"
    */
    function getValidatorInfo(uint validatorId) external returns (Validator memory validator) {
        revert("Not implemented");
    }

    /**
        @dev See {IHolderDelegation.getValidators}. "Not implemented"
    */
    function getValidators() external returns (uint[] memory validatorIds) {
        revert("Not implemented");
    }

    /**
        @dev See {IHolderDelegation.withdrawBounty}. "Not implemented"
    */
    function withdrawBounty(address bountyCollectionAddress, uint amount) external {
        revert("Not implemented");
    }

    /**
        @dev See {IHolderDelegation.getEarnedBountyAmount}. "Not implemented"
    */
    function getEarnedBountyAmount() external returns (uint) {
        revert("Not implemented");
    }

    /**
        @dev See {IValidatorDelegation.deleteNode}. "Not implemented"
    */
    function deleteNode(uint nodeIndex) external {
        revert("Not implemented");
    }

    /*
        @notice Makes all tokens of target account unavailable to move. "Not implemented"
        @dev "No interface" and "Not implemented"
    */
    function lock(address wallet, uint amount) external {
        revert("Lock is not implemented");
    }

    /*
        @notice Makes all tokens of target account available to move. "Not implemented"
        @dev "No interface" and "Not implemented"
    */
    function unlock(address target) external {
        revert("Not implemented");
    }

    /*
        @dev "No interface" and "Not implemented"
        call {IDelegatableToken-getLockedOf}
    */
    function getLockedOf(address wallet) external returns (bool) {
        revert("getLockedOf is not implemented");
        // return isDelegated(wallet) || _locked[wallet];
    }

    /*
       @dev "No interface" and "Not implemented"
            call {IDelegatableToken-getDelegatedOf}
    */
    function getDelegatedOf(address wallet) external returns (bool) {
        revert("isDelegatedOf is not implemented");
        // return DelegationManager(contractManager.getContract("DelegationManager")).isDelegated(wallet);
    }
}
