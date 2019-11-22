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

import "./interfaces/delegation/IHolderDelegation.sol";
import "./interfaces/delegation/IValidatorDelegation.sol";
import "./interfaces/delegation/internal/IManagerDelegationInternal.sol";


contract DelegationService is IHolderDelegation, IValidatorDelegation, IManagerDelegationInternal {
    function requestUndelegation() external {
        revert("Not implemented");
    }

    /// @notice Allows validator to accept tokens delegated at `requestId`
    function accept(uint requestId) external {
        revert("Not implemented");
    }

    /// @notice Adds node to SKALE network
    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp) external
    {
        revert("Not implemented");
    }

    function setMinimumDelegationAmount(uint amount) external {
        revert("Not implemented");
    }

    /// @notice Requests return of tokens that are locked in SkaleManager
    function returnTokens(uint amount) external {
        revert("Not implemented");
    }

    /// @notice Returns array of delegation requests id
    function listDelegationRequests() external returns (uint[] memory) {
        revert("Not implemented");
    }

    /// @notice Allows service to slash `validator` by `amount` of tokens
    function slash(address validator, uint amount) external {
        revert("Not implemented");
    }

    /// @notice Allows service to pay `amount` of tokens to `validator`
    function pay(address validator, uint amount) external {
        revert("Not implemented");
    }

    /// @notice Returns amount of delegated token of the validator
    function getDelegatedAmount(address validator) external returns (uint) {
        revert("Not implemented");
    }

    function setMinimumStakingRequirement(uint amount) external {
        revert("Not implemented");
    }

    /// @notice Creates request to delegate `amount` of tokens to `validator` from the begining of the next month
    function delegate(
        uint validatorId,
        uint delegationPeriod,
        string calldata info)
    external returns(uint requestId)
    {
        revert("Not implemented");
    }

    function cancelPendingDelegation(uint requestId) external {
        revert("Not implemented");
    }

    function getAllDelegationRequests() external returns(uint[] memory) {
        revert("Not implemented");
    }

    function getDelegationRequestsForValidator(uint validatorId) external returns (uint[] memory) {
        revert("Not implemented");
    }

    /// @notice Register new as validator
    function registerValidator(string calldata name, string calldata description, uint feeRate) external returns (uint validatorId) {
        // revert("Not implemented");
    }

    function unregisterValidator(uint validatorId) external {
        revert("Not implemented");
    }

    /// @notice return how many of validator funds are locked in SkaleManager
    function getBondAmount(uint validatorId) external returns (uint amount) {
        revert("Not implemented");
    }

    function setValidatorName(string calldata newName) external {
        revert("Not implemented");
    }

    function setValidatorDescription(string calldata descripton) external {
        revert("Not implemented");
    }

    function setValidatorAddress(address newAddress) external {
        revert("Not implemented");
    }

    function getValidatorInfo(uint validatorId) external returns (Validator memory validator) {
        revert("Not implemented");
    }

    function getValidators() external returns (uint[] memory validatorIds) {
        revert("Not implemented");
    }

    function withdrawBounty(address bountyCollectionAddress, uint amount) external {
        revert("Not implemented");
    }

    function getEarnedBountyAmount() external returns (uint) {
        revert("Not implemented");
    }

    /// @notice removes node from system
    function deleteNode(uint nodeIndex) external {
        revert("Not implemented");
    }

    /// @notice Makes all tokens of target account unavailable to move
    function lock(address target) external {
        revert("Not implemented");
    }

    /// @notice Makes all tokens of target account available to move
    function unlock(address target) external {
        revert("Not implemented");
    }
}