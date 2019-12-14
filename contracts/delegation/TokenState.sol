/*
    TokenState.sol - SKALE Manager
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
    @title Token State Contract
    @notice Stores and manages the tokens states
*/
contract TokenState {

    enum State {
        UNLOCKED,
        PROPOSED,
        ACCEPTED,
        DELEGATED,
        ENDING_DELEGATED,
        PURCHASED,
        PURCHASED_PROPOSED
    }

    /**
        @dev Not implemented!
        @notice get the total locked amount
        @param holder address of the token holder
        @return total locked amount
    */
    function getLockedCount(address holder) external returns (uint amount) {
        revert("getLockedCount is not implemented");
    }

    /**
        @dev Not implemented!
        @notice get the total delegated amount
        @param holder address of the token holder
        @return total delegated amount
    */
    function getDelegatedCount(address holder) external returns (uint amount) {
        revert("getLockedCount is not implemented");
    }

    /**
        @dev Not implemented!
        @notice get the total delegated amount
        @param delegationId Id of the delegator/request
        @return total delegated amount
    */
    function getState(uint delegationId) external returns (State state) {
        revert("Not implemented");
    }

    /**
        @dev Not Implemented!
        @notice modifies the token state
        @param delegationId Id of the delegator
        @param newState state of the delegatedToken
    */
    function setState(uint delegationId, State newState) external {
        revert("Not implemented");
    }

    /**
        @dev Not Implemented!
        @notice sets the amount purchased by the token holder
        @param holder token holder address
        @param amount amount of tokens that are purchased
    */
    function setPurchased(address holder, uint amount) external {
        revert("Not implemented");
    }
}
