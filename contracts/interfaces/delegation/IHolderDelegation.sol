/*
    IHolderDelegation.sol - SKALE Manager
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

/**
    @notice Delegation Request Calls
    @dev Calls by delegation holders(Delegator)
*/
interface IHolderDelegation {

    /**
        @notice Delegation Request sent event
        @param id request ID; If delegation is accepted, request ID becomes delegationID.
     */
    event DelegationRequestIsSent(uint id);

    /**
        @notice Creates request to delegate `amount` of tokens to `validatorId` from the beginning of the next month <br>
	            Executed by delegator wallet, emits request ID sent event. <br>
                Delegation requests expire after one week
       @param validatorId unique Id of the validator
       @param amount amount of delegation delegator sets up, Value needs to be less than total of the undelegated token value.
       @param delegationPeriod Currently: 3, 6, 12 months
       @param info description
    */
    function delegate(
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    ) external;

    /**
        @notice Undelegates a particular delegation, executed by token owner <br>
        Allows tokens holder to request return of it's token from validator <br>
        This will succeed only if delegation period passed
        @param delegationId Id of the delegation request
     */
    function requestUndelegation(uint delegationId) external;

    /**
        @notice Removes delegation request for this delegator wallet
        @param requestId Id of the delegation Request
    */
    function cancelPendingDelegation(uint requestId) external;

    /**
        @notice Returns an array of pending delegation request IDs for this validator <br>
        Returns 0 if no request exists
        @param validatorId Id of the validator
        @return an array of pending delegation request IDs for this validator
    */
    function getDelegationRequestsForValidator(uint validatorId) external returns (uint[] memory);

    /**
        @notice get the list of registered validators
        @return list of registered validator Ids
    */
    function getValidators() external returns (uint[] memory validatorIds);

    /**
        @notice Withdraws bounty for particular delegation. Bounties will be locked for 3 months
        @param bountyCollectionAddress delegationID
        @param amount amount of bounty request to withdraw
     */
    function withdrawBounty(address bountyCollectionAddress, uint amount) external;

    /**
        @notice Get earned bounty for delegator
        @return Amount of earned bounties
     */
    function getEarnedBountyAmount() external returns (uint);

}
