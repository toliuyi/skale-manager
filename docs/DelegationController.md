# DelegationController.sol

View Source: [contracts/delegation/DelegationController.sol](../contracts/delegation/DelegationController.sol)

**↗ Extends: [Permissions](Permissions.md)**

**DelegationController**

Delegation Controller for executing delegation events

## Structs
### Delegation

```js
struct Delegation {
 uint256 amount,
 uint256 stakeEffectiveness,
 uint256 expirationDate
}
```

## Contract Members
**Constants & Variables**

```js
mapping(uint256 => mapping(address => struct DelegationController.Delegation[])) public delegations;
mapping(address => uint256) public effectiveDelegationsTotal;
mapping(uint256 => uint256) public delegationsTotal;
mapping(address => uint256) public delegated;

```

## Functions

- [(address newContractsAddress)](#)
- [delegate(uint256 requestId)](#delegate)
- [unDelegate(uint256 validatorId)](#undelegate)
- [calculateEndTime(uint256 months)](#calculateendtime)

### 

DelegationController constructor

```js
function (address newContractsAddress) public nonpayable Permissions 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newContractsAddress | address | registers for Permissions | 

### delegate

with this function validator finalizes the approval of a delegation request

```js
function delegate(uint256 requestId) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| requestId | uint256 | Id of the delegation requests | 

### unDelegate

undelegates a delegation from validator

```js
function unDelegate(uint256 validatorId) external view
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| validatorId | uint256 |  | 

### calculateEndTime

Calculates the expiration date of a delegation

```js
function calculateEndTime(uint256 months) public view
returns(endTime uint256)
```

**Returns**

sendTime expiration date of delegation

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| months | uint256 |  | 

