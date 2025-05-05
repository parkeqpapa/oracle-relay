// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import {IPriceWrapper} from './Wrapper.sol';
import {AggregatorV3Interface} from '@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol';


contract DataConsumerV3 is IPriceWrapper {
  AggregatorV3Interface internal dataFeed;


  constructor(
    address priceFeed
  ) {
    dataFeed = AggregatorV3Interface(priceFeed);
  }

  /**
   * Returns the latest answer.
   */
  function getChainlinkDataFeedLatestAnswer() internal view returns (int256) {
    // prettier-ignore
    (
      /* uint80 roundId */
      ,
      int256 answer,
      /*uint256 startedAt*/
      ,
      /*uint256 updatedAt*/
      ,
      /*uint80 answeredInRound*/
    ) = dataFeed.latestRoundData();

    return answer;
  }



  function getAmountOut(address _tokenIn, address _tokenOut, uint256 amountIn) external view returns (uint256) {
    address[] memory tokens = new address[](2);
    tokens[0] = _tokenIn;
    tokens[1] = _tokenOut;
    int256 priceInt = getChainlinkDataFeedLatestAnswer();

    return uint256(priceInt);
  }
}
