// SPDX-License-Identifier: AGPL-3.0-only

/*
    SkaleManager.sol - SKALE Manager
    Copyright (C) 2018-Present SKALE Labs
    @author Artem Payvin

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

pragma solidity 0.6.9;
pragma experimental ABIEncoderV2;

import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";

import "./Bounty.sol";
import "./Permissions.sol";
import "./ConstantsHolder.sol";
import "./SkaleToken.sol";
import "./delegation/Distributor.sol";
import "./delegation/ValidatorService.sol";
import "./Monitors.sol";
import "./Schains.sol";



contract SkaleManager is IERC777Recipient, Permissions {
    IERC1820Registry private _erc1820;

    bytes32 constant private _TOKENS_RECIPIENT_INTERFACE_HASH =
        0xb281fc8c12954d22544db45de3159a39272895b169a852b314f9cc762e44c53b;

    event BountyGot(
        uint indexed nodeIndex,
        address owner,
        uint averageDowntime,
        uint averageLatency,
        uint bounty,
        uint previousBlockEvent,
        uint time,
        uint gasSpend
    );

    function tokensReceived(
        address, // operator
        address from,
        address to,
        uint256 value,
        bytes calldata userData,
        bytes calldata // operator data
    )
        external override
        allow("SkaleToken")
    {
        require(to == address(this), "Receiver is incorrect");
        if (userData.length > 0) {
            Schains schains = Schains(
                contractManager.getContract("Schains"));
            schains.addSchain(from, value, userData);
        }
    }

    function createNode(
        uint16 port,
        uint16 nonce,
        bytes4 ip,
        bytes4 publicIp,
        bytes32[2] calldata publicKey,
        string calldata name)
        external
    {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));

        nodes.checkPossibilityCreatingNode(msg.sender);
        Nodes.NodeCreationParams memory params = Nodes.NodeCreationParams({
            name: name,
            ip: ip,
            publicIp: publicIp,
            port: port,
            publicKey: publicKey,
            nonce: nonce});
        uint nodeIndex = nodes.createNode(msg.sender, params);
        monitors.addMonitor(nodeIndex);
    }

    function nodeExit(uint nodeIndex) external {
        ValidatorService validatorService = ValidatorService(contractManager.getContract("ValidatorService"));
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        uint validatorId = nodes.getValidatorId(nodeIndex);
        bool permitted = (_isOwner() || nodes.isNodeExist(msg.sender, nodeIndex));
        if (!permitted) {
            permitted = validatorService.getValidatorId(msg.sender) == validatorId;
        }
        require(permitted, "Sender is not permitted to call this function");
        Schains schains = Schains(
            contractManager.getContract("Schains"));
        SchainsInternal schainsInternal = SchainsInternal(contractManager.getContract("SchainsInternal"));
        ConstantsHolder constants = ConstantsHolder(contractManager.getContract("ConstantsHolder"));
        schains.freezeSchains(nodeIndex);
        if (nodes.isNodeActive(nodeIndex)) {
            require(nodes.initExit(nodeIndex), "Initialization of node exit is failed");
        }
        bool completed;
        bool isSchains = false;
        if (schainsInternal.getActiveSchain(nodeIndex) != bytes32(0)) {
            completed = schains.exitFromSchain(nodeIndex);
            isSchains = true;
        } else {
            completed = true;
        }
        if (completed) {
            require(nodes.completeExit(nodeIndex), "Finishing of node exit is failed");
            nodes.changeNodeFinishTime(nodeIndex, now.add(isSchains ? constants.rotationDelay() : 0));
            Monitors monitors = Monitors(contractManager.getContract("Monitors"));
            monitors.removeCheckedNodes(nodeIndex);
            monitors.deleteMonitor(nodeIndex);
            nodes.deleteNodeForValidator(validatorId, nodeIndex);
        }
    }

    function deleteSchain(string calldata name) external {
        Schains schains = Schains(contractManager.getContract("Schains"));
        schains.deleteSchain(msg.sender, name);
    }

    function deleteSchainByRoot(string calldata name) external onlyOwner {
        Schains schains = Schains(contractManager.getContract("Schains"));
        schains.deleteSchainByRoot(name);
    }

    function sendVerdict(uint fromMonitorIndex, Monitors.Verdict calldata verdict) external {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));

        require(nodes.isNodeExist(msg.sender, fromMonitorIndex), "Node does not exist for Message sender");

        monitors.sendVerdict(fromMonitorIndex, verdict);
    }

    function sendVerdicts(uint fromMonitorIndex, Monitors.Verdict[] calldata verdicts) external {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        require(nodes.isNodeExist(msg.sender, fromMonitorIndex), "Node does not exist for Message sender");
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        for (uint i = 0; i < verdicts.length; i++) {
            monitors.sendVerdict(fromMonitorIndex, verdicts[i]);
        }
    }

    function getBounty(uint nodeIndex) external {
        Nodes nodes = Nodes(contractManager.getContract("Nodes"));
        require(nodes.isNodeExist(msg.sender, nodeIndex), "Node does not exist for Message sender");
        require(nodes.isTimeForReward(nodeIndex), "Not time for bounty");
        require(
            nodes.isNodeActive(nodeIndex) || nodes.isNodeLeaving(nodeIndex), "Node is not Active and is not Leaving"
        );
        Bounty bountyContract = Bounty(contractManager.getContract("Bounty"));
        uint averageDowntime;
        uint averageLatency;
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        (averageDowntime, averageLatency) = monitors.calculateMetrics(nodeIndex);
        
        uint bounty = bountyContract.getBounty(
            nodeIndex,
            averageDowntime,
            averageLatency);            
        
        nodes.changeNodeLastRewardDate(nodeIndex);
        monitors.deleteMonitor(nodeIndex);
        monitors.addMonitor(nodeIndex);

        if (bounty > 0) {
            _payBounty(bounty, nodes.getValidatorId(nodeIndex));
        }

        _emitBountyEvent(nodeIndex, msg.sender, averageDowntime, averageLatency, bounty);
    }

    function initialize(address newContractsAddress) public override initializer {
        Permissions.initialize(newContractsAddress);
        _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);
        _erc1820.setInterfaceImplementer(address(this), _TOKENS_RECIPIENT_INTERFACE_HASH, address(this));
    }

    function _payBounty(uint bounty, uint validatorId) private returns (bool) {        
        SkaleToken skaleToken = SkaleToken(contractManager.getContract("SkaleToken"));
        Distributor distributor = Distributor(contractManager.getContract("Distributor"));
        
        // solhint-disable-next-line check-send-result
        skaleToken.send(address(distributor), bounty, abi.encode(validatorId));
    }

    function _emitBountyEvent(
        uint nodeIndex,
        address from,
        uint averageDowntime,
        uint averageLatency,
        uint bounty
    )
        private
    {
        Monitors monitors = Monitors(contractManager.getContract("Monitors"));
        uint previousBlockEvent = monitors.getLastBountyBlock(nodeIndex);
        monitors.setLastBountyBlock(nodeIndex);

        emit BountyGot(
            nodeIndex,
            from,
            averageDowntime,
            averageLatency,
            bounty,
            previousBlockEvent,
            block.timestamp,
            gasleft());
    }
}
