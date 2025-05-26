// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyEscrow {

    // Replace this address with the token you created (or whatever token you want to use).
    address constant tokenToEscrow = 0x0105c6E84344c90218D79Afe8562E65d8BE2F852 ;
    // This tells the contract that the address you provided is a token that can be transferred.
    IERC20 escrowToken = IERC20(tokenToEscrow); 
    address public buyerAddress = address(0);
    address public sellerAddress = address(0);
    address public mediatorAddress = address(0);
    uint256 public amountToEscrow = 0 ;

    constructor() {
        /* This function creates the contract. */  
    }

    function openEscrow(uint256 escrowAmount, address escrowSeller, address escrowMediator) public payable {

        require(buyerAddress==address(0), "This account is already being used.");

        // Record the escrow information.
        buyerAddress = msg.sender;
        sellerAddress = escrowSeller;
        mediatorAddress = escrowMediator;
        amountToEscrow = escrowAmount;
        // Transfer to funds from the buyer to this contract.
        escrowToken.transferFrom(msg.sender, address(this), amountToEscrow);
    }

    function closeEscrow(uint256 paySeller) public {
        
        require(msg.sender==mediatorAddress, "Only the mediator can close this account");

        escrowToken.approve(address(this), amountToEscrow);
        if (paySeller==1) {
            // Pay the seller (transfer funds from this contract to seller wallet).
            escrowToken.transferFrom(address(this), sellerAddress, amountToEscrow);
        } else {
            // Return funds to the buyer (transfer funds from this contract to buyer wallet).
            escrowToken.transferFrom(address(this), payable(buyerAddress), amountToEscrow);
        }
        // Reset the variables so that the contract can be used again.
        buyerAddress = address(0);
        sellerAddress = address(0);
        mediatorAddress = address(0);
        amountToEscrow = 0;
    }


    /* Note: The following function is strictly for testing puposes.
        If your code above doesn't work for some reason, your tokens can get 
        stuck in the smart contract with no way to get them out.
        The cancel() function will send all the tokens back to your wallet.
        You should delete this function once your code is working correctly.
        If you don't someone could steal the tokens from the contract.
    */
    function cancel() public {
        escrowToken.approve(address(this), amountToEscrow);
        escrowToken.transferFrom(address(this), msg.sender, amountToEscrow);
    }
}
