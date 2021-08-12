// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

interface IPancakeCallee {
  function pancakeCall(
    address sender,
    uint256 amount0,
    uint256 amount1,
    bytes calldata data
  ) external;
}
