// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "../../BEP20/IBEP20.sol";

interface IPancakeERC20 is IBEP20 {
  /* solhint-disable func-name-mixedcase */

  function DOMAIN_SEPARATOR() external view returns (bytes32);

  function PERMIT_TYPEHASH() external pure returns (bytes32);

  /* solhint-enable func-name-mixedcase */

  function nonces(address owner) external view returns (uint256);

  function permit(
    address owner,
    address spender,
    uint256 value,
    uint256 deadline,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external;
}
