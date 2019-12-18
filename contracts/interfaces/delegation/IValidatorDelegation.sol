/*
    IValidatorDelegation.sol - SKALE Manager
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


/*
    @notice Delegation calls done by the validator <br>
    This interface registers a new validator and validator node to the system, <br>
    Provides validator info such as commission rate or minimum delegation amount,<br>
    Accepts/rejects delegations
*/
interface IValidatorDelegation {
    struct Validator {
        string name;
        address validatorAddress;
        string description;
        uint feeRate;
        uint registrationTime;
        uint minimumDelegationAmount;
    }

    /**
       @notice Allows validator to accept tokens delegated at `requestId`
       @param requestId returns request
    */
    function accept(uint delegationId) external;

    /**
        @notice Adds node to SKALE network
        @param port Port Validator Node
        @param nonce Node
        @param ip IP Address of the Validator node
        @param publicIp Public IP Address of the Validator node
        @return Returns registered validatorId
    */
    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp) external;

    /**
        @notice removes node from system
        @param nodeIndex index of Node
     */
    function deleteNode(uint nodeIndex) external;

    /**
        @notice Executed by a validator : Registers a new validator <br>
        sets validatorAddress to to the address of the caller
        @param name name of the validator
        @param description Validator Description
        @param feeRate Validator Commission Rate
        @return  Returns registered validatorId
    */
    function registerValidator(
        string calldata name,
        string calldata description,
        uint feeRatePromille,
        uint minimumDelegationAmount
    ) external returns (uint validatorId);

    /**
       @notice  Executed by a validator : Unregisters validator. <br>
        Returns false if the validator did not exist. Requires zero delegation and bond
       @param validatorId Id of the registered Validator
   */
    function unregisterValidator(uint validatorId) external;

    /**
       @notice return how many of validator funds are locked in SKALEManager
       @param validatorId Id of the registered Validator
       @return bond amount deposited by this validator
   */
    function getBondAmount(uint validatorId) external returns (uint amount);

    /**
        @notice sets validator name
        @param newName new Validator Name
    */
    function setValidatorName(string calldata newName) external;

    /**
        @notice sets validator address
        @param description Validator Description
    */
    function setValidatorDescription(string calldata description) external;

    /**
        @notice sets validator address
        @param newAddress validator address
    */
    function setValidatorAddress(address newAddress) external;

    /**
        @notice sets minimum delegation amount
        @param amount minimum delegation amount
    */
    function setMinimumDelegationAmount(uint amount) external;

    /**
       @notice returns the validator info as struct
       @param validatorId Id of the registered Validator
       @return the validator info as struct
   */
    function getValidatorInfo(uint validatorId) external returns (Validator memory validator);
}
