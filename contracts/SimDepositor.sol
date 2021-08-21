//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "./SimToken.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimDepositor is Ownable{

    SimToken internal token;

    constructor(address token_){
        token = SimToken(token_);
    }

    receive() external payable {
        token.mint(msg.sender,msg.value);
    }

    function sweep() external onlyOwner {
        bool res = payable(msg.sender).send(address(this).balance);
        require(res == true, "SimDepositor : Sweep Failed");
    }

}