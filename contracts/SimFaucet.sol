//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./SimToken.sol";

contract SimFaucet{

    SimToken internal token;

    uint public amount;
    uint public minWait;
    mapping(address => uint) public addressLastMint;

    constructor(address token_, uint amount_, uint minWait_){
        token = SimToken(token_);
        amount = amount_;
        minWait = minWait_;
    }

    function mint() public{
        require( ((addressLastMint[msg.sender] + minWait) < block.timestamp) , "SimFaucet : Cooldown not complete" );
        token.mint(msg.sender,amount);
        addressLastMint[msg.sender] = block.timestamp;
    }

}