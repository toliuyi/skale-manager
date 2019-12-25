pragma solidity ^0.5.3;

import "@openzeppelin/contracts/ownership/Ownable.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC777/IERC777Recipient.sol";
import "@openzeppelin/contracts/introspection/IERC1820Registry.sol";

import "../interfaces/tokenSale/ITokenSaleManager.sol";
import "../interfaces/delegation/IDelegatableToken.sol";
import "../Permissions.sol";
import "./DelegationService.sol";


/**
    @notice : Implements ITokenSaleManager interface <br>
    Token Sale Manager will initially hold all tokens for the sale and allow users to retrieve them.
    Implements the function from IERC777Recipient.tokensReceived <br>
*/
contract TokenSaleManager is ITokenSaleManager, Permissions, IERC777Recipient {
    IERC1820Registry private _erc1820 = IERC1820Registry(0x1820a4B7618BdE71Dce8cdc73aAB6C95905faD24);

    address seller;
    mapping (address => uint) approved;
    uint totalApproved;

    /**
        @notice Token Sale Manager Constructor
        @param _contractManager Contract Manager address
    */
    constructor(address _contractManager) Permissions(_contractManager) public {
        _erc1820.setInterfaceImplementer(address(this), keccak256("ERC777TokensRecipient"), address(this));
    }

    /**
        @notice Implementation of the ITokenSaleManager.approve function <br>
        Allocates values for `walletAddresses` <br>
        At the end of the sale token approval function will be called (can be called multiple times) <br>
        @dev value[i] will be allocated to walletAddress[i]
        @param walletAddress array of addresses that the tokens will be sent
        @param value array of the values of the tokens that will be sent to each address

        Requirement
        -
        Seller should be authorized to distribute tokens to addresses
        WalletAddress length should be equal to value
        Balance of the seller should be more than the total approved amount
    */
    function approve(address[] calldata walletAddress, uint[] calldata value) external {
        require(isOwner() || _msgSender() == seller, "Not authorized");
        require(walletAddress.length == value.length, "Wrong input arrays length");
        for (uint i = 0; i < walletAddress.length; ++i) {
            approved[walletAddress[i]] += value[i];
            totalApproved += value[i];
        }
        require(totalApproved <= getBalance(), "Balance is too low");
    }

    /**
        @notice Implementation of the ITokenSaleManager.retrieve function <br>
        Transfers the entire value to sender address. Tokens are locked. <br>
        Each sale participant calls retrieve() - the entire value is transferred to walletAddress<br>
        After the transfer, the token in walletAddress will be locked through DelegationService contract<br>
        User will be able to see the token in the wallet.
    */
    function retrieve() external {
        require(approved[_msgSender()] > 0, "Transfer is not approved");
        uint value = approved[_msgSender()];
        approved[_msgSender()] = 0;
        require(IERC20(contractManager.getContract("SkaleToken")).transfer(_msgSender(), value), "Error of token sending");
        DelegationService(contractManager.getContract("DelegationService")).lock(_msgSender(), value);
    }

    /**
        @notice Implementation of the ITokenSaleManager.registerSeller function <br>
                Allows seller address to approve tokens transfers
        @param _seller seller address of the wallet
    */
    function registerSeller(address _seller) external onlyOwner {
        seller = _seller;
    }

    /**
     * @dev Not implemented!
     * Called by an {IERC777} token contract whenever tokens are being
     * moved or created into a registered account (`to`). The type of operation
     * is conveyed by `from` being the zero address or not.
     *
     * This call occurs _after_ the token contract's state is updated, so
     * {IERC777-balanceOf}, etc., can be used to query the post-operation state.
     *
     * This function may revert to prevent the operation from being executed.
     */
    function tokensReceived(
        address operator,
        address from,
        address to,
        uint256 amount,
        bytes calldata userData,
        bytes calldata operatorData
    )
        external
    {

    }

    /**
         @notice internal function to get balance from ERC-20 contract through contract manager <br>
         This will be used to check if an address have enough balance
         @return the balance of the current address
    */
    function getBalance() internal returns(uint balance) {
        return IERC20(contractManager.getContract("SkaleToken")).balanceOf(address(this));
    }
}
