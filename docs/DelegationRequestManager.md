# DelegationRequestManager.sol

View Source: [contracts/delegation/DelegationRequestManager.sol](../contracts/delegation/DelegationRequestManager.sol)

**↗ Extends: [Permissions](Permissions.md)**

**DelegationRequestManager**

Handles Delegation Requests <br>
Requests are created/canceled by the delegator <br>
Requests are accepted by the validator

## Structs
### DelegationRequest

```js
struct DelegationRequest {
 address tokenAddress,
 uint256 validatorId,
 uint256 amount,
 uint256 delegationPeriod,
 uint256 unlockedUntill,
 string description
}
```

## Contract Members
**Constants & Variables**

```js
struct DelegationRequestManager.DelegationRequest[] public delegationRequests;
mapping(address => uint256[]) public delegationRequestsByTokenAddress;

```

## Modifiers

- [checkValidatorAccess](#checkvalidatoraccess)

### checkValidatorAccess

checks if validator has access to change the status of a request

```js
modifier checkValidatorAccess(uint256 requestId) internal
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| requestId | uint256 | Id of the delegation request
Requirements
-
Delegation request should exist
Transaction sender should have permissions to change status of request | 

## Functions

- [(address newContractsAddress)](#)
- [getDelegationRequest(uint256 requestId)](#getdelegationrequest)
- [createRequest(address tokenAddress, uint256 validatorId, uint256 amount, uint256 delegationPeriod, string info)](#createrequest)
- [cancelRequest(uint256 requestId)](#cancelrequest)
- [acceptRequest(uint256 requestId)](#acceptrequest)
- [checkValidityRequest(uint256 requestId)](#checkvalidityrequest)
- [calculateExpirationRequest()](#calculateexpirationrequest)

### 

Delegation request manager constructor

```js
function (address newContractsAddress) public nonpayable Permissions 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newContractsAddress | address | to register for Permissions | 

### getDelegationRequest

get a specific Delegation Request

```js
function getDelegationRequest(uint256 requestId) external view
returns(address, uint256, uint256, uint256)
```

**Returns**

tokenAddress : token address of the delegator <br>
validatorId : Id of the validator<br>
amount : amount of tokens to be used for delegation<br>
delegationPeriod : preferred delegation period

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| requestId | uint256 | Id of the Delegation Request | 

### createRequest

creates a Delegation Request

```js
function createRequest(address tokenAddress, uint256 validatorId, uint256 amount, uint256 delegationPeriod, string info) external nonpayable
returns(requestId uint256)
```

**Returns**

requestId: Id of the delegation request
Requirement
-
Delegation period should be allowed
Validator should be registered
Delegator should have enough tokens to delegate, checks the account holder balance through SKALEToken contract

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| tokenAddress | address | token address of the delegator | 
| validatorId | uint256 | Id of the validator | 
| amount | uint256 | amount of tokens to be used for delegation | 
| delegationPeriod | uint256 | delegation period (3,6,12) | 
| info | string | information about the delegation request | 

### cancelRequest

cancels a Delegation Request

```js
function cancelRequest(uint256 requestId) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| requestId | uint256 | Id of the delegation Request
Requirement
-
Delegation request should exist
Only token holder can cancel request | 

### acceptRequest

validator calls this function to accept a Delegation Request

```js
function acceptRequest(uint256 requestId) external nonpayable checkValidatorAccess 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| requestId | uint256 | Id of the delegation Request
Requirement
-
Only token holder can cancel request | 

### checkValidityRequest

checks if a request is still valid or expired

```js
function checkValidityRequest(uint256 requestId) public view
returns(bool)
```

**Returns**

true if request Id is still valid
Requirement
-
Token Address should exist

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| requestId | uint256 | Id of the delegation Request | 

### calculateExpirationRequest

Calculates the expiration date of a request.

```js
function calculateExpirationRequest() private view
returns(timestamp uint256)
```

**Returns**

timestamp value of the 1st date of the following month

