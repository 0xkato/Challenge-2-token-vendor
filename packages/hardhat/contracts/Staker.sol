// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import "hardhat/console.sol";
import "./ExampleExternalContract.sol";

contract Staker {

  ExampleExternalContract public exampleExternalContract;

  event Stake(address sender, uint256 amount);
  event Withdraw(address indexed sender, uint256 amount);

  mapping ( address => uint256 ) public balances;
  uint256 public constant threshold = 1 ether;
  uint256 public deadline = block.timestamp + 72 hours;

  modifier stakeNotCompleted() {
    bool completed = exampleExternalContract.completed();
    require(!completed, "staking process already completed");
    _;
  }

  constructor(address exampleExternalContractAddress) {
      exampleExternalContract = ExampleExternalContract(exampleExternalContractAddress);
  }

  // Collect funds in a payable `stake()` function and track individual `balances` with a mapping:
  // ( Make sure to add a `Stake(address,uint256)` event and emit it for the frontend <List/> display )
function stake() public payable stakeNotCompleted {
  balances[msg.sender] += msg.value;

  emit Stake(msg.sender, msg.value);
}

  // After some `deadline` allow anyone to call an `execute()` function
  // If the deadline has passed and the threshold is met, it should call `exampleExternalContract.complete{value: address(this).balance}()`
function execute() public stakeNotCompleted{
    require(deadline <= block.timestamp, "Deadline not reached");
    if (address(this).balance >= threshold) {
      exampleExternalContract.complete{value: address(this).balance}();
    }
}

  // If the `threshold` was not met, allow everyone to call a `withdraw()` function


  // Add a `withdraw()` function to let users withdraw their balance
  function withdraw() public stakeNotCompleted {
    require(balances[msg.sender] > 0);
    require(timeLeft() <= 0);

    uint256 amount = balances[msg.sender];
    balances[msg.sender] = 0;

    (bool sent, ) = msg.sender.call{value: amount}("");
    require(sent, "Failed to send user balance back to the user");

    emit Withdraw(msg.sender, amount);

  }


  // Add a `timeLeft()` view function that returns the time left before the deadline for the frontend
function timeLeft() public view returns (uint256 timeleft) {
  if (block.timestamp >= deadline) {
    return 0;
  } else {
  return deadline - block.timestamp;
  }
}

  // Add the `receive()` special function that receives eth and calls stake()
receive() external payable stakeNotCompleted {
  balances[msg.sender] += msg.value;
  console.log(balances[msg.sender]);

  emit Stake(msg.sender, msg.value);
}

}
