// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract DBC is ERC20 {

    address public minter;

    event MinterChanged(address from, address to);

    constructor() payable ERC20("Decentralized Bank Currency", "DBC") {
        minter = msg.sender;
    }

    function passMinterRole(address newMinterAddress) public returns (bool){
        //check if msg.sender have minter role
        require(msg.sender == minter, "msg.sender does not have minter role!");
        minter = newMinterAddress;
        emit MinterChanged(msg.sender, newMinterAddress);
        return true;
    }

    function mint(address account, uint256 amount) public {
        //check if msg.sender have minter role
        require(msg.sender == minter, "msg.sender does not have minter role!");
        _mint(account, amount);
    }
}
