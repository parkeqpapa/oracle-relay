// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {IPriceWrapper} from 'src/Wrapper.sol';
import {ICurvePool} from 'src/interfaces/ICurve.sol';

contract CurveWrapper is IPriceWrapper {
  address public immutable curvePool;
  IERC20 public DAI_ADDRESS = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IERC20 public USDT_ADDRESS = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  IERC20 public USDC_ADDRESS = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

  constructor(
    address _curvePool
  ) {
    curvePool = _curvePool;
  }

  function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view override returns (uint256) {
    (int128 i, int128 j) = getIndices(tokenIn, tokenOut);
    return ICurvePool(curvePool).get_dy(i, j, amountIn);
  }

  function getIndices(address tokenIn, address tokenOut) internal view returns (int128, int128) {
    if (tokenIn == address(DAI_ADDRESS) && tokenOut == address(USDC_ADDRESS)) return (0, 1);
    if (tokenIn == address(DAI_ADDRESS) && tokenOut == address(USDT_ADDRESS)) return (0, 2);
    if (tokenIn == address(USDC_ADDRESS) && tokenOut == address(DAI_ADDRESS)) return (1, 0);
    if (tokenIn == address(USDC_ADDRESS) && tokenOut == address(USDT_ADDRESS)) return (1, 2);
    if (tokenIn == address(USDT_ADDRESS) && tokenOut == address(DAI_ADDRESS)) return (2, 0);
    if (tokenIn == address(USDT_ADDRESS) && tokenOut == address(USDC_ADDRESS)) return (2, 1);
    revert('Unsupported pair');
  }
}
