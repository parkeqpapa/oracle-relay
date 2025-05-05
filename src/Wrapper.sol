// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import { Ownable } from '@openzeppelin/contracts/access/Ownable.sol';

interface IPriceWrapper {
  function getAmountOut(address tokenIn, address tokenOut, uint256 amountIn) external view returns (uint256);
}

contract Wrapper is Ownable {

  // Mapeo para wrappers de pares de tokens
  mapping(bytes32 => address) public pairWrappers;

  // Mapeo para wrappers de tokens individuales
  mapping(address => address) public tokenWrappers;

  // Wrapper predeterminado
  address public defaultWrapper;

   error InvalidAddress();
    error NoWrapperFound();
  // Eventos
  event PairWrapperSet(address tokenA, address tokenB, address wrapper);
  event TokenWrapperSet(address token, address wrapper);
  event DefaultWrapperSet(address wrapper);

  // Constructor
  constructor(
    address _defaultWrapper
  ) Ownable(msg.sender) {
    require(_defaultWrapper != address(0), 'Invalid default wrapper');
    defaultWrapper = _defaultWrapper;
    emit DefaultWrapperSet(_defaultWrapper);
  }

  // Función para establecer un wrapper para un par de tokens
    function setPairWrapper(
        address tokenA,
        address tokenB,
        address wrapper
    ) external onlyOwner {
        if (tokenA == address(0) || tokenB == address(0)) revert InvalidAddress();
        if (wrapper == address(0)) revert InvalidAddress();

        bytes32 pairKey = _getPairKey(tokenA, tokenB);
        pairWrappers[pairKey] = wrapper;

        emit PairWrapperSet(tokenA, tokenB, wrapper);
    }
  // Función para establecer un wrapper para un token individual
     function setTokenWrapper(address token, address wrapper) external onlyOwner {
        if (token == address(0)) revert InvalidAddress();
        if (wrapper == address(0)) revert InvalidAddress();

        tokenWrappers[token] = wrapper;

        emit TokenWrapperSet(token, wrapper);
    }

  // Función para establecer el wrapper predeterminado
     function setDefaultWrapper(address wrapper) external onlyOwner {
        if (wrapper == address(0)) revert InvalidAddress();

        defaultWrapper = wrapper;

        emit DefaultWrapperSet(wrapper);
    }

  // Función para obtener la cantidad de salida
    function getAmountOut(
        address tokenIn,
        address tokenOut,
        uint256 amountIn
    ) external view returns (uint256) {
        address wrapper = getWrapper(tokenIn, tokenOut);
        if (wrapper == address(0)) revert NoWrapperFound();

        return IPriceWrapper(wrapper).getAmountOut(tokenIn, tokenOut, amountIn);
    }
  

  function getBestAmountOut(
    address tokenIn,
    address tokenOut,
    uint256 amountIn
  ) external view returns (uint256, address) {
    uint256 bestAmountOut = 0;
    address bestWrapper = address(0);
    if (tokenWrappers[tokenIn] != address(0)) {
      uint256 amountOut = IPriceWrapper(tokenWrappers[tokenIn]).getAmountOut(tokenIn, tokenOut, amountIn);
      if (amountOut > bestAmountOut) {
        bestAmountOut = amountOut;
        bestWrapper = tokenWrappers[tokenIn];
      }
    }
    if (pairWrappers[_getPairKey(tokenIn, tokenOut)] != address(0)) {
      uint256 amountOut =
        IPriceWrapper(pairWrappers[_getPairKey(tokenIn, tokenOut)]).getAmountOut(tokenIn, tokenOut, amountIn);
      if (amountOut > bestAmountOut) {
        bestAmountOut = amountOut;
        bestWrapper = pairWrappers[_getPairKey(tokenIn, tokenOut)];
      }
    }
    if (defaultWrapper != address(0)) {
      uint256 amountOut = IPriceWrapper(defaultWrapper).getAmountOut(tokenIn, tokenOut, amountIn);
      if (amountOut > bestAmountOut) {
        bestAmountOut = amountOut;
        bestWrapper = defaultWrapper;
      }
    }
    return (bestAmountOut, bestWrapper);
  }

  // Función para obtener el wrapper adecuado para un par de tokens
  function getWrapper(address tokenIn, address tokenOut) public view returns (address) {
    // Verificar si hay un wrapper para el par de tokens
    bytes32 pairKey = _getPairKey(tokenIn, tokenOut);
    if (pairWrappers[pairKey] != address(0)) {
      return pairWrappers[pairKey];
    }

    // Verificar si hay un wrapper para el token de entrada
    if (tokenWrappers[tokenIn] != address(0)) {
      return tokenWrappers[tokenIn];
    }

    // Usar el wrapper predeterminado
    return defaultWrapper;
  }



  // Función auxiliar para generar una clave única para un par de tokens
  function _getPairKey(address tokenA, address tokenB) internal pure returns (bytes32) {
    return keccak256(abi.encodePacked(tokenA < tokenB ? tokenA : tokenB, tokenA < tokenB ? tokenB : tokenA));
  }
}
