// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract MyEscrow {

    address constant tokenToEscrow = 0x3c499c542cEF5E3811e1192ce70d8cC03d5c3359 ;
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

        buyerAddress = msg.sender;
        sellerAddress = escrowSeller;
        mediatorAddress = escrowMediator;
        amountToEscrow = escrowAmount;
        escrowToken.transferFrom(msg.sender, address(this), amountToEscrow);
    }

    function closeEscrow(uint256 paySeller) public {
        
        require(msg.sender==mediatorAddress, "Only the mediator can close this account");

        escrowToken.approve(address(this), amountToEscrow);
        if (paySeller==1) {
            escrowToken.transferFrom(address(this), sellerAddress, amountToEscrow);
        } else {
            escrowToken.transferFrom(address(this), payable(buyerAddress), amountToEscrow);
        }
        buyerAddress = address(0);
        sellerAddress = address(0);
        mediatorAddress = address(0);
        amountToEscrow = 0;
    }
