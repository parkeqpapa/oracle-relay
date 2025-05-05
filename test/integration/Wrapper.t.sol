// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Wrapper} from 'contracts/Wrapper.sol';
import {WETH9} from 'interfaces/IWETH.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test, console} from 'forge-std/Test.sol';

import {UniswapV3Twap} from 'src/Univ3.sol';

import {DataConsumerV3} from 'src/chainlink.sol';
import {CurveWrapper} from 'src/curve.sol';
import {UniswapV2Wrapper} from 'src/uni.sol';

contract WrapperTest is Test {
  uint256 internal constant _FORK_BLOCK = 22413375;

  address public governor = makeAddr('governor');
  address public alice = makeAddr('alice');
  Wrapper public wrapper;
  CurveWrapper public curveWrapper;
  UniswapV2Wrapper public uniWrapper;
  UniswapV2Wrapper public sushiWrapper;
  UniswapV3Twap public uniswapV3;
  DataConsumerV3 public chainlink;
  DataConsumerV3 public chainlink2;
  address public uniswapV3Factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
  address public uniswapV2Router = 0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D;
  address public sushiswapV2Router = 0xd9e1cE17f2641f24aE83637ab66a2cca9C378B9F;
  address public pool = 0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;
  address public chainlinkFeed = 0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c; // BTC/USD
  address public chainlinkFeed2 = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419; // ETH/USD

  WETH9 public weth = WETH9(0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2);
  IERC20 public dai = IERC20(0x6B175474E89094C44Da98b954EedeAC495271d0F);
  IERC20 public uni = IERC20(0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984);
  IERC20 public usdt = IERC20(0xdAC17F958D2ee523a2206206994597C13D831ec7);
  IERC20 public wbtc = IERC20(0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('mainnet'), _FORK_BLOCK);

    vm.startPrank(governor);
    wrapper = new Wrapper(governor);
    curveWrapper = new CurveWrapper(pool);
    uniWrapper = new UniswapV2Wrapper(uniswapV2Router);
    sushiWrapper = new UniswapV2Wrapper(sushiswapV2Router);
    uniswapV3 = new UniswapV3Twap(uniswapV3Factory);
    chainlink = new DataConsumerV3(chainlinkFeed);
    chainlink2 = new DataConsumerV3(chainlinkFeed2);
    vm.stopPrank();
    // it sets up the test
  }

   function test_getBestAmountOut() public {
    vm.startPrank(governor);
    wrapper.setDefaultWrapper(address(sushiWrapper));
    wrapper.setPairWrapper(address(weth), address(dai), address(chainlink2));
    wrapper.setTokenWrapper(address(weth), address(uniswapV3));
    (uint256 amountOut, address _wrapper) = wrapper.getBestAmountOut(address(weth), address(dai), 1e18);
    // solhint-disable-next-line
    console.log('amountOut', amountOut);
    // solhint-disable-next-line
    console.log('wrapper', _wrapper);    
    vm.stopPrank();
  }

  function test_getAmountOutWithDefaultWrapper() public {
    vm.startPrank(governor);
    wrapper.setDefaultWrapper(address(sushiWrapper));
    uint256 amountOut = wrapper.getAmountOut(address(weth), address(dai), 1e18);
    // solhint-disable-next-line
    console.log('amountOut With Default', amountOut);
    vm.stopPrank();
  }

  function test_getAmountOutWithPairWrapper() public {
    vm.startPrank(governor);
    wrapper.setPairWrapper(address(weth), address(dai), address(chainlink2));
    uint256 amountOut = wrapper.getAmountOut(address(weth), address(dai), 1e18);
    // solhint-disable-next-line
    console.log('amountOut With Pair', amountOut);
    vm.stopPrank();
  }

  function test_getAmountOutWithTokenWrapper() public {
    vm.startPrank(governor);
    wrapper.setTokenWrapper(address(weth), address(uniswapV3));
    uint256 amountOut = wrapper.getAmountOut(address(weth), address(dai), 1e18);
    // solhint-disable-next-line
    console.log('amountOut With Token', amountOut);
    vm.stopPrank();
  }

  function test_getAmountOutWithCurve() public {
    vm.startPrank(governor);
    wrapper.setPairWrapper(address(dai), address(usdt), address(curveWrapper));
    vm.stopPrank();
    uint256 amountOut = wrapper.getAmountOut(address(dai), address(usdt), 1e18);
    // solhint-disable-next-line
    console.log('amountOut With Curve', amountOut);
  }


}