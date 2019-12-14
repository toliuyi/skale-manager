/*
    ValidatorService.sol - SKALE Manager
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

import "../Permissions.sol";


/**
    @notice Validator Service handles all validator related information and registration
*/
contract ValidatorService is Permissions {

    struct Validator {
        string name;
        address validatorAddress;
        string description;
        uint feeRate;
        uint registrationTime;
        uint minimumDelegationAmount;
        uint lastBountyCollectionMonth;
    }

    Validator[] public validators;
    mapping (uint => address) public validatorIdtoAddress;

    /**
        @notice Constructor of a validator service registers newContract Address
        @param newContractsAddress to register for Permissions
    */
    constructor(address newContractsAddress) Permissions(newContractsAddress) public {

    }

    /**
        @notice Executed by a DelegationService.registerValidator : and registers a validator info <br>
        sets validatorAddress to to the address of the caller
        @param name name of the validator
        @param description Validator Description
        @param feeRate Validator Commission Rate
        @return registered validatorId
    */
    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRate,
        uint minimumDelegationAmount
    )
        external returns (uint validatorId)
    {
        validators.push(Validator(
            name,
            msg.sender,
            description,
            feeRate,
            now,
            minimumDelegationAmount,
            0
        ));
        validatorId = validators.length - 1;
    }

    /**
        @notice sets new address to validator
        @param validatorId Id of the validator
        @param newValidatorAddress new address of the the validator

        Requirements

        -  Sender should have permission to change the address
    */
    function setNewValidatorAddress(uint validatorId, address newValidatorAddress) external {
        require(
            msg.sender == validatorIdtoAddress[validatorId],
            "Sender Doesn't have permissions to change address for this validatorId"
        );
        validatorIdtoAddress[validatorId] = newValidatorAddress;
    }

    /*
        @notice checks if a specific Id exists as a validator
        @dev Used by DelegationRequestManager.checkRequest function
        @param validatorId Id of the validator
        @return whether the validator exists
    */
    function checkValidatorExists(uint validatorId) external view returns (bool) {
        return validatorId < validators.length ? true : false;
    }

    // function setValidatorFeeAddress(uint _validatorId, address _newAddress) public {
    //     require(msg.sender == validators[_validatorId].validatorAddress, "Transaction sender doesn't have enough permissions");
    //     validators[_validatorId].validatorFeeAddress = _newAddress;
    // }

    // function getValidatorFeeAddress(uint _validatorId) public view returns (address) {
    //     return validators[_validatorId].validatorFeeAddress;
    // }

    /**
        @notice this function is used by DelegationRequestManager.checkValidatorAccess <br>
        to check if a validatorId is matching the validatorAddress
        @param validatorId Registered Id of the validator
        @param validatorAddress address of the Validator
        @return whether the validatorAddress is valid
    */
    function checkValidatorIdToAddress(uint validatorId, address validatorAddress) external view returns (bool) {
        return validatorIdtoAddress[validatorId] == validatorAddress ? true : false;
    }
}
