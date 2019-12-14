pragma solidity ^0.5.3;

/**
    @notice interface of SKALE Token

*/
interface ISkaleToken {

    /**
    * @dev Moves `value` tokens from the caller's account to `address`.
    *
    * @param to Address to transfer SKALE tokens
    * @param value Transferred token Value
    * @return a boolean value indicating whether the operation succeeded.
    *
    */
    function transfer(address to, uint256 value) external returns (bool success);

    /**
     * @dev mint - create some amount of token and transfer it to specify address
     * @param operator address operator requesting the transfer
     * @param account - address where some amount of token would be created
     * @param amount - amount of tokens to mine
     * @param userData bytes extra information provided by the token holder (if any)
     * @param operatorData bytes extra information provided by the operator (if any)
     * @return success of function call.
     */
    function mint(
        address operator,
        address account,
        uint amount,
        bytes calldata userData,
        bytes calldata operatorData
    ) external returns (bool);
    function CAP() external view returns (uint);
}
