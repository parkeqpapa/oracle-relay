// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IPriceWrapper} from 'src/Wrapper.sol';
import {IUniswapV2Router02} from 'src/interfaces/IUniswap.sol';

contract UniswapV2Wrapper is IPriceWrapper {
  address public immutable UNISWAP_ROUTER;

  constructor(
    address _uniswapRouter
  ) {
    UNISWAP_ROUTER = _uniswapRouter;
  }

  function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view override returns (uint256) {
    address[] memory path = new address[](2);
    path[0] = tokenIn;
    path[1] = tokenOut;

    uint256[] memory amounts = IUniswapV2Router02(UNISWAP_ROUTER).getAmountsOut(amountIn, path);
    return amounts[1];
  }
}
