// SPDX-License-Identifier: MIT

pragma solidity 0.6.12;

import "@gsx/bsc-genesis/contracts/IWBNB.sol";
import "@uniswap/lib/contracts/libraries/TransferHelper.sol";
import "../interfaces/IPancakeRouter01.sol";
import "../interfaces/IPancakeFactory.sol";
import "../libraries/PancakeLibrary.sol";

contract PancakeRouter01 is IPancakeRouter01 {
  address public immutable override factory;

  // solhint-disable-next-line var-name-mixedcase
  address public immutable override WETH;

  modifier ensure(uint256 deadline) {
    require(deadline >= block.timestamp, "PancakeRouter: EXPIRED");
    _;
  }

  // solhint-disable-next-line func-param-name-mixedcase, var-name-mixedcase
  constructor(address _factory, address _WETH) public {
    factory = _factory;
    WETH = _WETH;
  }

  receive() external payable {
    assert(msg.sender == WETH); // only accept ETH via fallback from the WETH contract
  }

  // **** ADD LIQUIDITY ****
  function _addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin
  ) private returns (uint256 amountA, uint256 amountB) {
    // create the pair if it doesn't exist yet
    if (IPancakeFactory(factory).getPair(tokenA, tokenB) == address(0)) {
      IPancakeFactory(factory).createPair(tokenA, tokenB);
    }

    (uint256 reserveA, uint256 reserveB) = PancakeLibrary.getReserves(factory, tokenA, tokenB);

    if (reserveA == 0 && reserveB == 0) {
      (amountA, amountB) = (amountADesired, amountBDesired);
    } else {
      uint256 amountBOptimal = PancakeLibrary.quote(amountADesired, reserveA, reserveB);

      if (amountBOptimal <= amountBDesired) {
        require(amountBOptimal >= amountBMin, "PancakeRouter: INSUFFICIENT_B_AMOUNT");

        (amountA, amountB) = (amountADesired, amountBOptimal);
      } else {
        uint256 amountAOptimal = PancakeLibrary.quote(amountBDesired, reserveB, reserveA);

        assert(amountAOptimal <= amountADesired);

        require(amountAOptimal >= amountAMin, "PancakeRouter: INSUFFICIENT_A_AMOUNT");

        (amountA, amountB) = (amountAOptimal, amountBDesired);
      }
    }
  }

  function addLiquidity(
    address tokenA,
    address tokenB,
    uint256 amountADesired,
    uint256 amountBDesired,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  )
    external
    override
    ensure(deadline)
    returns (
      uint256 amountA,
      uint256 amountB,
      uint256 liquidity
    )
  {
    (amountA, amountB) = _addLiquidity(tokenA, tokenB, amountADesired, amountBDesired, amountAMin, amountBMin);

    address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);

    TransferHelper.safeTransferFrom(tokenA, msg.sender, pair, amountA);
    TransferHelper.safeTransferFrom(tokenB, msg.sender, pair, amountB);

    liquidity = IPancakePair(pair).mint(to);
  }

  function addLiquidityETH(
    address token,
    uint256 amountTokenDesired,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  )
    external
    payable
    override
    ensure(deadline)
    returns (
      uint256 amountToken,
      uint256 amountETH,
      uint256 liquidity
    )
  {
    (amountToken, amountETH) = _addLiquidity(token, WETH, amountTokenDesired, msg.value, amountTokenMin, amountETHMin);

    address pair = PancakeLibrary.pairFor(factory, token, WETH);

    TransferHelper.safeTransferFrom(token, msg.sender, pair, amountToken);

    IWBNB(WETH).deposit{ value: amountETH }();

    assert(IWBNB(WETH).transfer(pair, amountETH));

    liquidity = IPancakePair(pair).mint(to);

    if (msg.value > amountETH) TransferHelper.safeTransferETH(msg.sender, msg.value - amountETH); // refund dust eth, if any
  }

  // **** REMOVE LIQUIDITY ****
  function removeLiquidity(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256 amountA, uint256 amountB) {
    address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);

    IPancakePair(pair).transferFrom(msg.sender, pair, liquidity); // send liquidity to pair

    (uint256 amount0, uint256 amount1) = IPancakePair(pair).burn(to);
    (address token0, ) = PancakeLibrary.sortTokens(tokenA, tokenB);

    (amountA, amountB) = tokenA == token0 ? (amount0, amount1) : (amount1, amount0);

    require(amountA >= amountAMin, "PancakeRouter: INSUFFICIENT_A_AMOUNT");
    require(amountB >= amountBMin, "PancakeRouter: INSUFFICIENT_B_AMOUNT");
  }

  function removeLiquidityETH(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline
  ) public override ensure(deadline) returns (uint256 amountToken, uint256 amountETH) {
    (amountToken, amountETH) = removeLiquidity(
      token,
      WETH,
      liquidity,
      amountTokenMin,
      amountETHMin,
      address(this),
      deadline
    );
    TransferHelper.safeTransfer(token, to, amountToken);

    IWBNB(WETH).withdraw(amountETH);

    TransferHelper.safeTransferETH(to, amountETH);
  }

  function removeLiquidityWithPermit(
    address tokenA,
    address tokenB,
    uint256 liquidity,
    uint256 amountAMin,
    uint256 amountBMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override returns (uint256 amountA, uint256 amountB) {
    address pair = PancakeLibrary.pairFor(factory, tokenA, tokenB);
    uint256 value = approveMax ? uint256(-1) : liquidity;

    IPancakePair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);

    (amountA, amountB) = removeLiquidity(tokenA, tokenB, liquidity, amountAMin, amountBMin, to, deadline);
  }

  function removeLiquidityETHWithPermit(
    address token,
    uint256 liquidity,
    uint256 amountTokenMin,
    uint256 amountETHMin,
    address to,
    uint256 deadline,
    bool approveMax,
    uint8 v,
    bytes32 r,
    bytes32 s
  ) external override returns (uint256 amountToken, uint256 amountETH) {
    address pair = PancakeLibrary.pairFor(factory, token, WETH);
    uint256 value = approveMax ? uint256(-1) : liquidity;

    IPancakePair(pair).permit(msg.sender, address(this), value, deadline, v, r, s);

    (amountToken, amountETH) = removeLiquidityETH(token, liquidity, amountTokenMin, amountETHMin, to, deadline);
  }

  // **** SWAP ****
  // requires the initial amount to have already been sent to the first pair
  function _swap(
    uint256[] memory amounts,
    address[] memory path,
    address _to
  ) private {
    for (uint256 i; i < path.length - 1; i++) {
      (address input, address output) = (path[i], path[i + 1]);
      (address token0, ) = PancakeLibrary.sortTokens(input, output);
      uint256 amountOut = amounts[i + 1];
      (uint256 amount0Out, uint256 amount1Out) = input == token0 ? (uint256(0), amountOut) : (amountOut, uint256(0));
      address to = i < path.length - 2 ? PancakeLibrary.pairFor(factory, output, path[i + 2]) : _to;

      IPancakePair(PancakeLibrary.pairFor(factory, input, output)).swap(amount0Out, amount1Out, to, new bytes(0));
    }
  }

  function swapExactTokensForTokens(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint256[] memory amounts) {
    amounts = PancakeLibrary.getAmountsOut(factory, amountIn, path);

    require(amounts[amounts.length - 1] >= amountOutMin, "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT");

    TransferHelper.safeTransferFrom(path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]);

    _swap(amounts, path, to);
  }

  function swapTokensForExactTokens(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint256[] memory amounts) {
    amounts = PancakeLibrary.getAmountsIn(factory, amountOut, path);

    require(amounts[0] <= amountInMax, "PancakeRouter: EXCESSIVE_INPUT_AMOUNT");

    TransferHelper.safeTransferFrom(path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]);

    _swap(amounts, path, to);
  }

  function swapExactETHForTokens(
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[0] == WETH, "PancakeRouter: INVALID_PATH");

    amounts = PancakeLibrary.getAmountsOut(factory, msg.value, path);

    require(amounts[amounts.length - 1] >= amountOutMin, "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT");

    IWBNB(WETH).deposit{ value: amounts[0] }();

    assert(IWBNB(WETH).transfer(PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]));

    _swap(amounts, path, to);
  }

  function swapTokensForExactETH(
    uint256 amountOut,
    uint256 amountInMax,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[path.length - 1] == WETH, "PancakeRouter: INVALID_PATH");

    amounts = PancakeLibrary.getAmountsIn(factory, amountOut, path);

    require(amounts[0] <= amountInMax, "PancakeRouter: EXCESSIVE_INPUT_AMOUNT");

    TransferHelper.safeTransferFrom(path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]);

    _swap(amounts, path, address(this));

    IWBNB(WETH).withdraw(amounts[amounts.length - 1]);

    TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapExactTokensForETH(
    uint256 amountIn,
    uint256 amountOutMin,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[path.length - 1] == WETH, "PancakeRouter: INVALID_PATH");

    amounts = PancakeLibrary.getAmountsOut(factory, amountIn, path);

    require(amounts[amounts.length - 1] >= amountOutMin, "PancakeRouter: INSUFFICIENT_OUTPUT_AMOUNT");

    TransferHelper.safeTransferFrom(path[0], msg.sender, PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]);

    _swap(amounts, path, address(this));

    IWBNB(WETH).withdraw(amounts[amounts.length - 1]);

    TransferHelper.safeTransferETH(to, amounts[amounts.length - 1]);
  }

  function swapETHForExactTokens(
    uint256 amountOut,
    address[] calldata path,
    address to,
    uint256 deadline
  ) external payable override ensure(deadline) returns (uint256[] memory amounts) {
    require(path[0] == WETH, "PancakeRouter: INVALID_PATH");

    amounts = PancakeLibrary.getAmountsIn(factory, amountOut, path);

    require(amounts[0] <= msg.value, "PancakeRouter: EXCESSIVE_INPUT_AMOUNT");

    IWBNB(WETH).deposit{ value: amounts[0] }();

    assert(IWBNB(WETH).transfer(PancakeLibrary.pairFor(factory, path[0], path[1]), amounts[0]));

    _swap(amounts, path, to);

    if (msg.value > amounts[0]) TransferHelper.safeTransferETH(msg.sender, msg.value - amounts[0]); // refund dust eth, if any
  }

  function quote(
    uint256 amountA,
    uint256 reserveA,
    uint256 reserveB
  ) public pure override returns (uint256 amountB) {
    return PancakeLibrary.quote(amountA, reserveA, reserveB);
  }

  function getAmountOut(
    uint256 amountIn,
    uint256 reserveIn,
    uint256 reserveOut
  ) public pure override returns (uint256 amountOut) {
    return PancakeLibrary.getAmountOut(amountIn, reserveIn, reserveOut);
  }

  function getAmountIn(
    uint256 amountOut,
    uint256 reserveIn,
    uint256 reserveOut
  ) public pure override returns (uint256 amountIn) {
    return PancakeLibrary.getAmountOut(amountOut, reserveIn, reserveOut);
  }

  function getAmountsOut(uint256 amountIn, address[] memory path)
    public
    view
    override
    returns (uint256[] memory amounts)
  {
    return PancakeLibrary.getAmountsOut(factory, amountIn, path);
  }

  function getAmountsIn(uint256 amountOut, address[] memory path)
    public
    view
    override
    returns (uint256[] memory amounts)
  {
    return PancakeLibrary.getAmountsIn(factory, amountOut, path);
  }
}
