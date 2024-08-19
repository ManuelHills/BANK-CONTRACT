// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;


interface IERC20 {
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    // event Transfer(address indexed from, address indexed to, uint256 value);
    // event Approval(address indexed owner, address indexed spender, uint256 value);
  }


contract Bank {
    IERC20 public TO12 ;

  constructor(address _TO12){
    TO12 = IERC20(_TO12);
  }
    struct UserProfile {
        string name;
        address userAddress;
        uint256 balance;
    }

    mapping(address => UserProfile) public users;

    uint256 public constant MIN_DEPOSIT_AMOUNT = 0.01 ether;
    uint256 public constant MAX_WITHDRAWAL_AMOUNT = 10 ether;

    // Modifier to ensure the minimum deposit amount
    modifier minDeposit(uint256 amount) {
        require(amount >= MIN_DEPOSIT_AMOUNT, "Deposit amount is too low");
        _;
    }

    // Modifier to ensure the maximum withdrawal amount
    modifier maxWithdrawal(uint256 amount) {
        require(amount <= MAX_WITHDRAWAL_AMOUNT, "Withdrawal amount exceeds maximum limit");
        _;
    }

    // Modifier to ensure the caller is not a contract
    modifier onlyEOA() {
        require(msg.sender == tx.origin, "Caller cannot be a contract");
        _;
    }

    // Function to register a user profile
    function registerUser(string memory name) public onlyEOA {
        require(bytes(name).length > 0, "Name cannot be empty");
        users[msg.sender] = UserProfile(name, msg.sender, 0);
    }

    // Function to update the user's name
    function updateUserName(string memory name) public onlyEOA {
        require(bytes(name).length > 0, "Name cannot be empty");
        require(bytes(users[msg.sender].name).length > 0, "User not registered");
        users[msg.sender].name = name;
    }

    // Deposit function with minimum deposit check
    function deposit(uint256 amount) public onlyEOA minDeposit(amount) {
        require(bytes(users[msg.sender].name).length > 0, "User not registered");
        users[msg.sender].balance += amount;
        TO12.transferFrom(msg.sender, address(this), amount);
    }

    function _deposit() public payable onlyEOA minDeposit(msg.value) {
        require(bytes(users[msg.sender].name).length > 0, "User not registered");
        users[msg.sender].balance += msg.value;
    }

    // Withdraw function with maximum withdrawal check
    function withdraw(uint256 amount) public onlyEOA maxWithdrawal(amount) {
        require(bytes(users[msg.sender].name).length > 0, "User not registered");
        require(amount <= users[msg.sender].balance, "Insufficient balance");
        users[msg.sender].balance -= amount;
         TO12.transferFrom(address(this), msg.sender, amount);
        payable(msg.sender).transfer(amount);
    }

    // Get user profile
    function getUserProfile(address user) public view returns (string memory, address, uint256) {
        UserProfile memory profile = users[user];
        return (profile.name, profile.userAddress, profile.balance);
    }
}
