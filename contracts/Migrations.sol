// SPDX-License-Identifier: MIT

pragma solidity ^0.5.0;

contract Migrations {
  address public owner = msg.sender;
  uint256 public lastCompletedMigration;

  modifier restricted() {
    require(msg.sender == owner, "Restricted to the contract owner");
    _;
  }

  function setCompleted(uint256 completed) public restricted {
    lastCompletedMigration = completed;
  }
}
