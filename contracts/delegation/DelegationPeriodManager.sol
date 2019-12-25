/*
    DelegationPeriodManager.sol - SKALE Manager
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

import "../Permissions.sol";


/**
    @notice Manager handles the values for the stake multiplier <br>
    or delegation periods that are supported by the network
*/
contract DelegationPeriodManager is Permissions {
    mapping (uint => uint) public stakeMultipliers;

    /**
        @notice constructor which registers newContractsAddress
        @param newContractsAddress new contract address to register for permissions
    */
    constructor(address newContractsAddress) Permissions(newContractsAddress) public {
        stakeMultipliers[3] = 100;
        stakeMultipliers[6] = 150;
        stakeMultipliers[12] = 200;
    }

    /**
       @notice Returns the stake multiplier for this delegation period  <br>
       A multiplier to calculate the various yields per delegation period. e.g. 3m = 1, 6m = 1.5, 12m = 2
       @return the stake multiplier for this delegation period
    */
    function getStakeMultiplier(uint monthsCount) external view returns (uint) {
        require(isDelegationPeriodAllowed(monthsCount), "Stake multiplier didn't set for this period");
        return stakeMultipliers[monthsCount];
    }

    /**
        @notice Returns the set of allowed delegation period
        @dev Not implemented!
        @return All allowed delegation periods
     */
    function getDelegationPeriods() external returns(uint[] memory) {
        //Not yet Implemented!
    }

    /**
        @notice checks whether the delegation period is allowed in the system
        @param monthsCount delegation period
     */
    function setDelegationPeriod(uint monthsCount, uint stakeMultiplier) external onlyOwner {
        stakeMultipliers[monthsCount] = stakeMultiplier;
    }

    /**
        @notice removes a delegation period from the stake multiplier. </br>
        @dev If we set delegation period for 2 weeks and
             this is the option to remove it if it's too short and hurts the network.
        @param monthsCount delegation period
     */
    function removeDelegationPeriod(uint monthsCount) external onlyOwner {
        // remove only if there is no guys that stacked tokens for this period
        stakeMultipliers[monthsCount] = 0;
    }

    /**
        @notice checks whether the delegation period is allowed in the system
        @param monthsCount delegation period
        @return true if delegation period is allowed
    */
    function isDelegationPeriodAllowed(uint monthsCount) public view returns (bool) {
        return stakeMultipliers[monthsCount] != 0 ? true : false;
    }
}
