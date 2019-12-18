/*
    DelegationRequestManager.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Vadim Yavorsky
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
import "./DelegationPeriodManager.sol";
import "./ValidatorService.sol";
import "../interfaces/delegation/IDelegatableToken.sol";
import "../thirdparty/BokkyPooBahsDateTimeLibrary.sol";
import "./ValidatorService.sol";
import "./DelegationController.sol";
import "../SkaleToken.sol";
import "./TokenState.sol";


/**
    @notice Handles Delegation Requests <br>
            Requests are created/canceled by the delegator <br>
            Requests are accepted by the validator
*/
contract DelegationRequestManager is Permissions {

    struct DelegationRequest {
        address tokenAddress;
        uint validatorId;
        uint amount;
        uint delegationPeriod;
        uint unlockedUntill;
        string description;
    }

    DelegationRequest[] public delegationRequests;
    mapping (address => uint[]) public delegationRequestsByTokenAddress;

    /**
        @notice Delegation request manager constructor
        @param newContractsAddress to register for Permissions
    */
    constructor(address newContractsAddress) Permissions(newContractsAddress) public {

    }

    /**
        @notice checks if validator has access to change the status of a request
        @param requestId Id of the delegation request

        Requirements
        -
        Delegation request should exist
        Transaction sender should have permissions to change status of request
    */
    modifier checkValidatorAccess(uint requestId) {
        ValidatorService validatorService = ValidatorService(
            contractManager.getContract("ValidatorService")
        );
        require(requestId < delegationRequests.length, "Delegation request doesn't exist");
        require(
            validatorService.checkValidatorIdToAddress(delegationRequests[requestId].validatorId, msg.sender),
            "Transaction sender hasn't permissions to change status of request"
        );
        _;
    }

    /**
        @notice get a specific Delegation Request
        @param requestId Id of the Delegation Request
        @return tokenAddress : token address of the delegator <br>
                validatorId : Id of the validator<br>
                amount : amount of tokens to be used for delegation<br>
                delegationPeriod : preferred delegation period
    */
    function getDelegationRequest(uint requestId) external view returns (address, uint, uint, uint) {
        DelegationRequest memory delegationRequest = delegationRequests[requestId];
        return (
            delegationRequest.tokenAddress,
            delegationRequest.validatorId,
            delegationRequest.amount,
            delegationRequest.delegationPeriod
        );
    }

    /**
        @notice creates a Delegation Request
        @dev Changes TokenState to PROPOSED!
        @param tokenAddress token address of the delegator
        @param validatorId Id of the validator
        @param amount amount of tokens to be used for delegation
        @param delegationPeriod delegation period (3,6,12)
        @param info information about the delegation request
        @return requestId: Id of the delegation request

        Requirement
        -
        Delegation period should be allowed
        Validator should be registered
        Delegator should have enough tokens to delegate, checks the account holder balance through SKALEToken contract
    */
    function createRequest(
        address tokenAddress,
        uint validatorId,
        uint amount,
        uint delegationPeriod,
        string calldata info
    )
        external returns(uint requestId)
    {
        ValidatorService validatorService = ValidatorService(
            contractManager.getContract("ValidatorService")
        );
        TokenState tokenState = TokenState(contractManager.getContract("TokenState"));
        // require(!delegated[tokenAddress], "Token is already in the process of delegation");
        require(
            DelegationPeriodManager(
                contractManager.getContract("DelegationPeriodManager")
            ).isDelegationPeriodAllowed(delegationPeriod),
            "This delegation period is not allowed"
        );
        uint holderBalance = SkaleToken(contractManager.getContract("SkaleToken")).balanceOf(tokenAddress);
        require(validatorService.checkValidatorExists(validatorId), "Validator is not registered");
        uint expirationRequest = calculateExpirationRequest();
        delegationRequests.push(DelegationRequest(
            tokenAddress,
            validatorId,
            amount,
            delegationPeriod,
            expirationRequest,
            info
        ));
        requestId = delegationRequests.length-1;
        delegationRequestsByTokenAddress[tokenAddress].push(requestId);
        uint lockedTokens = tokenState.getLockedCount(tokenAddress);
        require(holderBalance - lockedTokens >= amount, "Delegator hasn't enough tokens to delegate");
    }

    /**
        @notice cancels a Delegation Request
        @param requestId Id of the delegation Request

        Requirement
        -
        Delegation request should exist
        Only token holder can cancel request
    */
    function cancelRequest(uint requestId) external {
        require(requestId < delegationRequests.length, "Delegation request doesn't exist");
        require(
            msg.sender == delegationRequests[requestId].tokenAddress,
            "Only token holder can cancel request"
        );
        TokenState tokenState = TokenState(contractManager.getContract("TokenState"));
        // tokenState.cancel(requestId);
        revert("cancelRequest is not implemented");
    }

    /**
        @notice validator calls this function to accept a Delegation Request
        @param requestId Id of the delegation Request

        Requirement
        -
        Only token holder can cancel request
    */
    function acceptRequest(uint requestId) external checkValidatorAccess(requestId) {
        DelegationController delegationController = DelegationController(
            contractManager.getContract("DelegationController")
        );
        TokenState tokenState = TokenState(contractManager.getContract("TokenState"));
        require(
            tokenState.getState(requestId) == TokenState.State.PROPOSED,
            "Validator cannot accept request for delegation, because it's not proposed"
        );
        tokenState.accept(requestId);

        require(checkValidityRequest(requestId), "Validator can't longer accept delegation request");
        delegationController.delegate(requestId);
    }

    /**
        @notice checks if a request is still valid or expired
        @param requestId Id of the delegation Request
        @return true if request Id is still valid

        Requirement
        -
        Token Address should exist
    */
    function checkValidityRequest(uint requestId) public view returns (bool) {
        require(delegationRequests[requestId].tokenAddress != address(0), "Token address doesn't exist");
        return delegationRequests[requestId].unlockedUntill > now ? true : false;
    }

    // function getAllDelegationRequests() public view returns (DelegationRequest[] memory) {
    //     return delegationRequests;
    // }

    // function getDelegationRequestsForValidator(uint validatorId) external returns (DelegationRequest[] memory) {

    // }

    /**
        @notice Calculates the expiration date of a request.
        @dev first calendar date of the following month <br>
             This will be assigned to struct attribute value of DelegationRequest.unlockedUntil
        @return timestamp value of the 1st date of the following month
    */
    function calculateExpirationRequest() private view returns (uint timestamp) {
        uint year;
        uint month;
        uint nextYear;
        uint nextMonth;
        (year, month, ) = BokkyPooBahsDateTimeLibrary.timestampToDate(now);
        if (month != 12) {
            nextMonth = month + 1;
            nextYear = year;
        } else {
            nextMonth = 1;
            nextYear = year + 1;
        }
        timestamp = BokkyPooBahsDateTimeLibrary.timestampFromDate(nextYear, nextMonth, 1);
    }

}
