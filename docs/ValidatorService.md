# ValidatorService.sol

View Source: [contracts/delegation/ValidatorService.sol](../contracts/delegation/ValidatorService.sol)

**↗ Extends: [Permissions](Permissions.md)**

**ValidatorService**

Validator Service handles all validator related information and registration

## Structs
### Validator

```js
struct Validator {
 string name,
 address validatorAddress,
 string description,
 uint256 feeRate,
 uint256 registrationTime,
 uint256 minimumDelegationAmount,
 uint256 lastBountyCollectionMonth
}
```

## Contract Members
**Constants & Variables**

```js
struct ValidatorService.Validator[] public validators;
mapping(uint256 => address) public validatorIdtoAddress;

```

## Functions

- [(address newContractsAddress)](#)
- [registerValidator(string name, string description, uint256 feeRate, uint256 minimumDelegationAmount)](#registervalidator)
- [setNewValidatorAddress(uint256 validatorId, address newValidatorAddress)](#setnewvalidatoraddress)
- [checkValidatorExists(uint256 validatorId)](#checkvalidatorexists)
- [checkValidatorIdToAddress(uint256 validatorId, address validatorAddress)](#checkvalidatoridtoaddress)

### 

Constructor of a validator service registers newContract Address

```js
function (address newContractsAddress) public nonpayable Permissions 
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| newContractsAddress | address | to register for Permissions | 

### registerValidator

Executed by a DelegationService.registerValidator : and registers a validator info <br>
sets validatorAddress to to the address of the caller

```js
function registerValidator(string name, string description, uint256 feeRate, uint256 minimumDelegationAmount) external nonpayable
returns(validatorId uint256)
```

**Returns**

registered validatorId

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| name | string | name of the validator | 
| description | string | Validator Description | 
| feeRate | uint256 | Validator Commission Rate | 
| minimumDelegationAmount | uint256 |  | 

### setNewValidatorAddress

sets new address to validator

```js
function setNewValidatorAddress(uint256 validatorId, address newValidatorAddress) external nonpayable
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| validatorId | uint256 | Id of the validator | 
| newValidatorAddress | address | new address of the the validator
Requirements
-  Sender should have permission to change the address | 

### checkValidatorExists

```js
function checkValidatorExists(uint256 validatorId) external view
returns(bool)
```

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| validatorId | uint256 |  | 

### checkValidatorIdToAddress

this function is used by DelegationRequestManager.checkValidatorAccess <br>
to check if a validatorId is matching the validatorAddress

```js
function checkValidatorIdToAddress(uint256 validatorId, address validatorAddress) external view
returns(bool)
```

**Returns**

whether the validatorAddress is valid

**Arguments**

| Name        | Type           | Description  |
| ------------- |------------- | -----|
| validatorId | uint256 | Registered Id of the validator | 
| validatorAddress | address | address of the Validator | 

