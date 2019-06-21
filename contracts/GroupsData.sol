pragma solidity ^0.5.0;

import './Permissions.sol';


/**
 * @title GroupsData - contract with some Groups data, will be inherited by
 * SchainsData and ValidatorsData.
 */
contract GroupsData is Permissions {

    // struct to note which Node has already joined to the group
    struct GroupCheck {
        mapping (uint => bool) check;
    }

    struct Group {
        bool active;
        bytes32 groupData;
        uint[] nodesInGroup;
        uint recommendedNumberOfNodes;
        // BLS master public key
        uint[4] groupsPublicKey;
    }

    // contain all groups
    mapping (bytes32 => Group) public groups;
    // mapping for checking Has Node already joined to the group
    mapping (bytes32 => GroupCheck) exceptions;

    // name of executor contract
    string executorName;

    /**
     * @dev constructor in Permissions approach
     * @param newExecutorName - name of executor contract
     * @param newContractsAddress needed in Permissions constructor
     */
    constructor(string memory newExecutorName, address newContractsAddress) public Permissions(newContractsAddress) {
        executorName = newExecutorName;
    }

    /**
     * @dev addGroup - creates and adds new Group to mapping
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     * @param amountOfNodes - recommended number of Nodes in this Group
     * @param data - some extra data
     */
    function addGroup(bytes32 groupIndex, uint amountOfNodes, bytes32 data) public allow(executorName) {
        groups[groupIndex].active = true;
        groups[groupIndex].recommendedNumberOfNodes = amountOfNodes;
        groups[groupIndex].groupData = data;
    }

    /**
     * @dev setException - sets a Node like exception
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     * @param nodeIndex - index of Node which would be notes like exception
     */
    function setException(bytes32 groupIndex, uint nodeIndex) public allow(executorName) {
        exceptions[groupIndex].check[nodeIndex] = true;
    }

    /**
     * @dev setPublicKey - sets BLS master public key
     * function could be run only by SkaleDKG
     * @param groupIndex - Groups identifier
     * @param publicKeyx1 }
     * @param publicKeyy1 } parts of BLS master public key
     * @param publicKeyx2 }
     * @param publicKeyy2 }
     */
    function setPublicKey(bytes32 groupIndex, uint publicKeyx1, uint publicKeyy1, uint publicKeyx2, uint publicKeyy2) public allow("SkaleDKG") {
        groups[groupIndex].groupsPublicKey[0] = publicKeyx1;
        groups[groupIndex].groupsPublicKey[1] = publicKeyy1;
        groups[groupIndex].groupsPublicKey[2] = publicKeyx2;
        groups[groupIndex].groupsPublicKey[3] = publicKeyy2;
    }

    /**
     * @dev setNodeInGroup - adds Node to Group
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     * @param nodeIndex - index of Node which would be added to the Group
     */
    function setNodeInGroup(bytes32 groupIndex, uint nodeIndex) public allow(executorName) {
        groups[groupIndex].nodesInGroup.push(nodeIndex);
    }

    /**
     * @dev removeAllNodesInGroup - removes all added Nodes out the Group
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     */
    function removeAllNodesInGroup(bytes32 groupIndex) public allow(executorName) {
        delete groups[groupIndex].nodesInGroup;
        groups[groupIndex].nodesInGroup.length = 0;
    }

    /**
     * @dev setNodesInGroup - adds Nodes to Group
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     * @param nodesInGroup - array of indexes of Nodes which would be added to the Group
    */
    function setNodesInGroup(bytes32 groupIndex, uint[] memory nodesInGroup) public allow(executorName) {
        groups[groupIndex].nodesInGroup = nodesInGroup;
    }

    /**
     * @dev setNewAmountOfNodes - set new recommended number of Nodes
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     * @param amountOfNodes - recommended number of Nodes in this Group
    */
    function setNewAmountOfNodes(bytes32 groupIndex, uint amountOfNodes) public allow(executorName) {
        groups[groupIndex].recommendedNumberOfNodes = amountOfNodes;
    }

    /**
     * @dev setNewGroupData - set new extra data
     * function could be run only be executor
     * @param groupIndex - Groups identifier
     * @param data - new extra data
     */
    function setNewGroupData(bytes32 groupIndex, bytes32 data) public allow(executorName) {
        groups[groupIndex].groupData = data;
    }

    /**
     * @dev removeGroup - remove Group from storage
     * function could be run only be executor
     * @param groupIndex - Groups identifier
     */
    function removeGroup(bytes32 groupIndex) public allow(executorName) {
        groups[groupIndex].active = false;
        delete groups[groupIndex].groupData;
        delete groups[groupIndex].recommendedNumberOfNodes;
    }

    /**
     * @dev removeExceptionNode - remove exception Node from Group
     * function could be run only by executor
     * @param groupIndex - Groups identifier
     */
    function removeExceptionNode(bytes32 groupIndex, uint nodeIndex) public allow(executorName) {
        exceptions[groupIndex].check[nodeIndex] = false;
    }

    /**
     * @dev isGroupActive - checks is Group active
     * @param groupIndex - Groups identifier
     * @return true - active, false - not active
     */
    function isGroupActive(bytes32 groupIndex) public view returns (bool) {
        return groups[groupIndex].active;
    }

    /**
     * @dev isExceptionNode - checks is Node - exception at given Group
     * @param groupIndex - Groups identifier
     * @param nodeIndex - index of Node
     * return true - exception, false - not exception
     */
    function isExceptionNode(bytes32 groupIndex, uint nodeIndex) public view returns (bool) {
        return exceptions[groupIndex].check[nodeIndex];
    }

    /**
     * @dev getGroupsPublicKey - shows Groups public key
     * @param groupIndex - Groups identifier
     * @return publicKey(x1, y1, x2, y2) - parts of BLS master public key
     */
    function getGroupsPublicKey(bytes32 groupIndex) public view returns (uint, uint, uint, uint) {
        return (groups[groupIndex].groupsPublicKey[0], groups[groupIndex].groupsPublicKey[1], groups[groupIndex].groupsPublicKey[2], groups[groupIndex].groupsPublicKey[3]);
    }

    /**
     * @dev getNodesInGroup - shows Nodes in Group
     * @param groupIndex - Groups identifier
     * @return array of indexes of Nodes in Group
     */
    function getNodesInGroup(bytes32 groupIndex) public view returns (uint[] memory) {
        return groups[groupIndex].nodesInGroup;
    }

    /**
     * @dev getGroupsData - shows Groups extra data
     * @param groupIndex - Groups identifier
     * @return Groups extra data
     */
    function getGroupData(bytes32 groupIndex) public view returns (bytes32) {
        return groups[groupIndex].groupData;
    }

    /**
     * @dev getRecommendedNumberOfNodes - shows recommended number of Nodes
     * @param groupIndex - Groups identifier
     * @return recommended number of Nodes
     */
    function getRecommendedNumberOfNodes(bytes32 groupIndex) public view returns (uint) {
        return groups[groupIndex].recommendedNumberOfNodes;
    }

    /**
     * @dev getNumberOfNodesInGroup - shows number of Nodes in Group
     * @param groupIndex - Groups identifier
     * @return number of Nodes in Group
     */
    function getNumberOfNodesInGroup(bytes32 groupIndex) public view returns (uint) {
        return groups[groupIndex].nodesInGroup.length;
    }
}