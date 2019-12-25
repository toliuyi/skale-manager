pragma solidity ^0.5.3;
/**
    @notice Token Sale Manager will initially hold all tokens for the sale and allow users to retrieve them
*/
interface ITokenSaleManager {

    /**
        @notice Allocates values for `walletAddresses` <br>
        At the end of the sale token approval function will be called (can be called multiple times)
        @dev value[i] will be allocated to walletAddress[i]
        @param walletAddress array of addresses that the tokens will be sent
        @param value array of the values of the tokens that will be sent to each address
    */
    function approve(address[] calldata walletAddress, uint[] calldata value) external;

    /**
        @notice  Transfers the entire value to sender address. Tokens are locked. <br>
        Each sale participant calls retrieve() - the entire value is transferred to walletAddress<br>
        After the transfer, the token in walletAddress will be locked through DelegationService contract<br>
        User will be able to see the token in the wallet.
    */
    function retrieve() external;

    /**
        @notice Allows seller address to approve tokens transfers
        @param seller seller address of the wallet
    */
    function registerSeller(address seller) external;
}
