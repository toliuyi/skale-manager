// SPDX-License-Identifier: AGPL-3.0-only

/*
    BountyScheduler.sol - SKALE Manager
    Copyright (C) 2020-Present SKALE Labs
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

pragma solidity 0.6.10;

import "./delegation/TimeHelpers.sol";
import "./Permissions.sol";
import "./ConstantsHolder.sol";

contract BountyScheduler is Permissions {
    struct CompositionChange {
        uint timestamp;
        
    }

    uint public constant STAGE_LENGTH = 31558150; // 1 year
    uint public constant YEAR1_BOUNTY = 3850e5 * 1e18;
    uint public constant YEAR2_BOUNTY = 3465e5 * 1e18;
    uint public constant YEAR3_BOUNTY = 3080e5 * 1e18;
    uint public constant YEAR4_BOUNTY = 2695e5 * 1e18;
    uint public constant YEAR5_BOUNTY = 2310e5 * 1e18;
    uint public constant YEAR6_BOUNTY = 1925e5 * 1e18;
    uint public constant BOUNTY = 96250000 * 1e18;
    
    uint private _nextStage;    

    //      month => tokens
    mapping (uint => uint) private _totalBounty;
    uint private _totalBountyLastProcessedMonth;

    function allocateBounty(uint nodeIndex) external allow("Bounty") returns (uint) {

    }

    function addNode(uint nodeIndex) external allow("Nodes") {

    }

    function removeNode(uint nodeIndex) external allow("Nodes") {

    }

    function returnBountyToPool(uint amount) external allow("Bounty") {

    }

    function initialize(address contractManagerAddress) public override initializer {
        Permissions.initialize(contractManagerAddress);
        _totalBountyLastProcessedMonth = 0;
        _nextStage = 0;
    }

    // private

    function _getStageBeginningTimestamp(uint stage, ConstantsHolder constantsHolder) private view returns (uint) {
        return constantsHolder.launchTimestamp().add(stage.mul(STAGE_LENGTH));
    }    

    function _getStageReward(uint stage) private pure returns (uint) {
        if (stage >= 6) {
            return BOUNTY.div(2 ** stage.sub(6).div(3));
        } else {
            if (stage == 0) {
                return YEAR1_BOUNTY;
            } else if (stage == 1) {
                return YEAR2_BOUNTY;
            } else if (stage == 2) {
                return YEAR3_BOUNTY;
            } else if (stage == 3) {
                return YEAR4_BOUNTY;
            } else if (stage == 4) {
                return YEAR5_BOUNTY;
            } else {
                return YEAR6_BOUNTY;
            }
        }
    }

    function _updateTotalBounty() private {
        TimeHelpers timeHelpers = TimeHelpers(contractManager.getContract("TimeHelpers"));
        ConstantsHolder constantsHolder = ConstantsHolder(contractManager.getContract("ConstantsHolder"));

        uint currentMonth = timeHelpers.getCurrentMonth();
        uint currentMonthEnd = timeHelpers.monthToTimestamp(currentMonth + 1);
        uint stage;
        for (stage = _nextStage; _getStageBeginningTimestamp(stage, constantsHolder) < currentMonthEnd ; ++stage) {
            uint reward = _getStageReward(stage);
            uint stageBegin = _getStageBeginningTimestamp(stage, constantsHolder);
            uint stageEnd = _getStageBeginningTimestamp(stage + 1, constantsHolder);
            for (
                uint month = timeHelpers.timestampToMonth(stageBegin);
                timeHelpers.monthToTimestamp(month) < stageEnd;
                ++month
            ) {
                uint monthBegin = timeHelpers.monthToTimestamp(month);
                uint monthEnd = timeHelpers.monthToTimestamp(month + 1);
                _totalBounty[month] = _totalBounty[month].add(
                    reward.mul(monthEnd.sub(monthBegin)).div(STAGE_LENGTH)
                );
            }
        }
        if (stage != _nextStage) {
            _nextStage = stage;
        }
    }
}