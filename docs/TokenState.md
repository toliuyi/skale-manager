# Token State Contract (TokenState.sol)

View Source: [contracts/delegation/TokenState.sol](../contracts/delegation/TokenState.sol)

**TokenState**

Stores and manages the tokens states

**Enums**
### State

```js
enum State {
 UNLOCKED,
 PROPOSED,
 ACCEPTED,
 DELEGATED,
 ENDING_DELEGATED,
 PURCHASED,
 PURCHASED_PROPOSED
}
```

## Functions

- [getLockedCount(address holder)](#getlockedcount)
- [getDelegatedCount(address holder)](#getdelegatedcount)
- [getState(uint256 delegationId)](#getstate)
- [setState(uint256 delegationId, enum TokenState.State newState)](#setstate)
- [setPurchased(address holder, uint256 amount)](#setpurchased)

### getLockedCount

get the total locked amount

```js
function getLockedCount(address holder) external nonpayable
returns(amount uint256)
```

**Returns**

total locked amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| holder | address | address of the token holder | 

### getDelegatedCount

get the total delegated amount

```js
function getDelegatedCount(address holder) external nonpayable
returns(amount uint256)
```

**Returns**

total delegated amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| holder | address | address of the token holder | 

### getState

get the total delegated amount

```js
function getState(uint256 delegationId) external nonpayable
returns(state enum TokenState.State)
```

**Returns**

total delegated amount

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| delegationId | uint256 | Id of the delegator/request | 

### setState

modifies the token state

```js
function setState(uint256 delegationId, enum TokenState.State newState) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| delegationId | uint256 | Id of the delegator | 
| newState | enum TokenState.State | state of the delegatedToken | 

### setPurchased

sets the amount purchased by the token holder

```js
function setPurchased(address holder, uint256 amount) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| holder | address | token holder address | 
| amount | uint256 | amount of tokens that are purchased | 

