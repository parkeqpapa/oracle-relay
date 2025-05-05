//SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {IUniswapV3Factory} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Factory.sol';
import {IUniswapV3Pool} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import {TickMath} from '@uniswap/v3-core/contracts/libraries/TickMath.sol';
import {OracleLibrary} from 'lib/v3-periphery/contracts/libraries/OracleLibrary.sol';

contract UniswapV3Twap {
  IUniswapV3Factory public immutable factory;
  uint24 public constant DEFAULT_FEE = 3000;
  uint32 public constant DEFAULT_PERIOD = 1800; 

  // Eventos
  event PriceQueried(
    address indexed tokenIn, address indexed tokenOut, uint24 fee, uint32 period, uint256 amountIn, uint256 amountOut
  );

  constructor(
    address _factory
  ) {
    require(_factory != address(0), 'Factory address cannot be zero');
    factory = IUniswapV3Factory(_factory);
  }

  function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256) {
    return _getResult(tokenIn, tokenOut, DEFAULT_FEE, DEFAULT_PERIOD, amountIn);
  }

  function _getResult(
    address tokenIn,
    address tokenOut,
    uint24 fee,
    uint32 period,
    uint256 amountIn
  ) internal view returns (uint256 amountOut) {
    require(tokenIn != tokenOut, 'Same tokens');
    require(amountIn > 0, 'Amount must be positive');
    require(period > 0, 'Period must be positive');

    address pool = factory.getPool(tokenIn, tokenOut, fee);
    require(pool != address(0), "Pool doesn't exist");

    IUniswapV3Pool uniswapPool = IUniswapV3Pool(pool);

    (int24 arithmeticMeanTick,) = OracleLibrary.consult(pool, period);

    bool isToken0 = tokenIn == uniswapPool.token0();

    if (isToken0) {
      amountOut = OracleLibrary.getQuoteAtTick(arithmeticMeanTick, uint128(amountIn), tokenIn, tokenOut);
    } else {
      amountOut = OracleLibrary.getQuoteAtTick(arithmeticMeanTick, uint128(amountIn), tokenIn, tokenOut);
    }

    return amountOut;
  }
}
