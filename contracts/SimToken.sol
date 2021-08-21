//SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract SimToken is ERC20,Ownable{

    mapping(address => bool) internal isAdmin;

    constructor(string memory name_, string memory symbol_) ERC20(name_,symbol_){}

    function mint(address to, uint amount) public{
        require(isAdmin[msg.sender],"SimToken : Mint Permission Error");
        _mint(to,amount);
    }

    function burn(address to, uint amount) public{
        require(isAdmin[msg.sender],"SimToken : Burn Permission Error");
        _burn(to,amount);
    }

    function approveAdmin(address admin, bool status) public onlyOwner{
        isAdmin[admin] = status;
    }

    function transferFromViaAdmin(address sender, address recipient, uint amount) public{
        require(isAdmin[msg.sender],"SimToken : transferFromViaAdmin Permission Error");
        _transfer(sender, recipient, amount);
    }

}