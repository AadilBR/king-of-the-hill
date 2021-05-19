// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";


contract KingOfTheHill{
    using Address for address payable;
    
    //States variables
    
    address private _owner;
    uint256 private _percentage;
    uint256 private _profit;
    uint256 private _tax;
    uint256 private _pot;
    mapping(address => uint256) private _balances;
    uint256 constant private MAX_PLAYERS = 50; // obligation d'initiliaser la variable
    
    address public currentKing;
    uint256 public lastKingBlock;
    
    
    //Events
    
    event Deposited(address indexed sender, uint256 amount);
    
    event Transfered(address indexed sender, address indexed recipient, uint256 amount);
    
    
    
    //constructor
    
    constructor (uint256 tax_, uint256 lastKingBlock, uint256 pot_) public payable {
        require(tax_<= 10, "KingOfTheHill: maximum tax 10 pourcent")
        _owner = msg.sender;
        _tax = tax_;
        lastKingBlock = block.number;
        
    }
    
    constructor(address owner_, uint256 tax_) Ownable(owner_) {
        require(tax_ >= 0 && tax_ <= 100, "KingOfTheHill: Invalid percentage");
        _tax = tax_;
        _owner = owner_;
    }
    
    //Modifiers
    
    modifier onlyOwner() {
        require(msg.sender == _owner, "Ownable: Only owner can call this function");
        _;
    }

    modifier onlyGoodPercentage(uint256 percentage) {
        require( percentage >= 0 && percentage <= 100, "KingOfTheHill: Not a valid percentage");
         _;
    }
    
    
    
    //Fonctions
    
    receive() external payable {
        _deposit(msg.sender, msg.value);
    }
    
    function _deposit(address sender, uint256 amount) private {
        _balances[sender] += amount;
        _depositTime[sender] = block.timestamp;
        emit Deposited(sender, amount);
    }
    
    function setTax(uint256 percentage) public onlyOwner onlyGoodPercentage(percentage) {
        require(percentage_ >= 0 && percentage_ <= 100, "SmartWallet: Invalid percentage");
        _percentage = percentage_;
    }
    
    
    
    function tax() public view returns (uint256) {
        return _tax;
    }
    
    function withdrawProfit() public onlyOwner {
        require(_profit > 0, "SmartWallet: can not withdraw 0 ether");
        uint256 amount = _profit;
        _profit = 0;
        payable(msg.sender).sendValue(amount);
    }
    
    function Transfer(address recipient, uint256 amount) public {
        require(
            _balances[msg.sender] > 0,
            "SmartWallet: can not transfer 0 ether"
        );
        require(
            _balances[msg.sender] >= amount,
            "SmartWallet: Not enough Ether to transfer"
        );
        require(
            recipient != address(0),
            "SmartWallet: transfer to the zero address"
        );
        _balances[msg.sender] -= amount;
        _balances[recipient] += amount;
        emit Transfered(msg.sender, recipient, amount, block.timestamp);
    }
    
    function total() public view returns (uint256) {
        return address(this).balance;
    }
    
    function tax() public view returns (uint256) {
        return _percentage;
    }
    
    function profit() public view returns (uint256) {
        return _profit;
    }
    
    function owner() public view returns (address) {
        return _owner;
    }
    
    }