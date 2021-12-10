// SPDX-License-Identifier: MIT
pragma solidity >=0.4.22 <0.9.0;

import "./DBC.sol";

contract Bank {

    DBC private dbc;

    mapping(address => uint) public depositStart;
    mapping(address => uint) public etherBalanceOf;
    mapping(address => bool) public isDeposited;

    event Deposit(address indexed user, uint etherAmount, uint timeStart);
    event Withdraw(address indexed user, uint etherAmount, uint depositTime, uint interest);


    constructor (DBC _dbc){
        dbc = _dbc;
    }

    function deposit() payable public {
        //check if address deposit before
        require(isDeposited[msg.sender] == false, 'Error, deposit already active');
        //check if deposit is more than 0.01 ETH or not
        require(msg.value >= 1e16, 'Error, deposit must be >= 0.01 ETH');
        //save address and amout of ETH in etherBalanceOf mapping
        etherBalanceOf[msg.sender] = etherBalanceOf[msg.sender] + msg.value;
        //save address and time in depositStart mapping
        depositStart[msg.sender] = depositStart[msg.sender] + block.timestamp;
        //activate deposit status
        isDeposited[msg.sender] = true;
        //fire the Deposit event
        emit Deposit(msg.sender, msg.value, block.timestamp);
    }

    function withdraw() payable public {
        //check if address deposit before or not
        require(isDeposited[msg.sender] == true, 'Error, no previous deposit');
        //get the balance of deposited value
        uint userBalance = etherBalanceOf[msg.sender];
        //for event

        //check user's hodl time
        uint depositTime = block.timestamp - depositStart[msg.sender];

        //31668017 - interest(10% APY) per second for min. deposit amount (0.01 ETH), cuz:
        //1e15(10% of 0.01 ETH) / 31577600 (seconds in 365.25 days)

        //(etherBalanceOf[msg.sender] / 1e16) - calc. how much higher interest will be (based on deposit), e.g.:
        //for min. deposit (0.01 ETH), (etherBalanceOf[msg.sender] / 1e16) = 1 (the same, 31668017/s)
        //for deposit 0.02 ETH, (etherBalanceOf[msg.sender] / 1e16) = 2 (doubled, (2*31668017)/s)
        uint interestPerSecond = 31668017 * (etherBalanceOf[msg.sender] / 1e16);
        uint interest = interestPerSecond * depositTime;
        //send eth funds back to user
        payable(msg.sender).transfer(etherBalanceOf[msg.sender]);
        //mint DBC token for address
        dbc.mint(msg.sender, interest);
        //reset depositer data
        depositStart[msg.sender] = 0;
        etherBalanceOf[msg.sender] = 0;
        isDeposited[msg.sender] = false;
        emit Withdraw(msg.sender, userBalance, depositTime, interest);
    }
}
