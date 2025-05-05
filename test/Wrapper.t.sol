// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.23;

import {Wrapper} from '../src/Wrapper.sol';
import {WETH9} from '../src/interfaces/IWETH.sol';
import {IERC20} from '@openzeppelin/contracts/token/ERC20/IERC20.sol';
import {Test} from 'forge-std/Test.sol';

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
  address public oneInchRouter = 0x0AdDd25a91563696D8567Df78D5A01C9a991F9B8;
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

  function test_ConstructorWhenCalledWithAddressIsPassed() external {
    // it deploys
    // it sets the approval to uniswap
    // it sets the governor
    vm.startPrank(governor);
    wrapper = new Wrapper(governor);
    vm.stopPrank();
  }

  function test_ConstructorWhenPassingAnInvalidAddress() external {
    // // it reverts
    vm.prank(governor);
    vm.expectRevert();
    wrapper = new Wrapper(address(0));
  }

  modifier whenCalledByTheGovernor() {
    vm.startPrank(governor);
    _;
    vm.stopPrank();
  }

  function test_SetPairWrapperWhenPassingAValidAddress() external whenCalledByTheGovernor {
    // it sets the pair wrapper

    wrapper.setPairWrapper(address(usdt), address(dai), address(curveWrapper));
  }

 
  function test_SetPairWrapperWhenPassingAnInvalidAddress() external whenCalledByTheGovernor {
    // it reverts
    vm.expectRevert();
    wrapper.setPairWrapper(address(usdt), address(dai), address(0));
  }

  function test_SetPairWrapperWhenCalledByANon_governor() external {
    // it reverts
    vm.startPrank(alice);
    vm.expectRevert();
    wrapper.setPairWrapper(address(dai), address(weth), address(curveWrapper));
    vm.stopPrank();
  }

  function test_SetTokenWrapperWhenPassingAValidAddress() external whenCalledByTheGovernor {
    // it sets the token wrapper
    // it emits TokenWrapperSet
    wrapper.setTokenWrapper(address(weth), address(uniWrapper));
  }

  function test_SetTokenWrapperWhenPassingAnInvalidAddress() external whenCalledByTheGovernor {
    // it reverts
    vm.expectRevert();
    wrapper.setTokenWrapper(address(weth), address(0));
  }

  function test_SetTokenWrapperWhenCalledByANon_governor() external {
    // it reverts
    vm.startPrank(alice);
    vm.expectRevert();
    wrapper.setTokenWrapper(address(weth), address(sushiWrapper));
    vm.stopPrank();
  }

  function test_SetDefaultWrapperWhenPassingAValidAddress() external whenCalledByTheGovernor {
    // it sets the default wrapper
    // it emits DefaultWrapperSet
    wrapper.setDefaultWrapper(address(uniWrapper));
  }

  function test_SetDefaultWrapperWhenPassingAnInvalidAddress() external whenCalledByTheGovernor {
    // it reverts
    vm.expectRevert();
    wrapper.setDefaultWrapper(address(0));
  }

  function test_SetDefaultWrapperWhenCalledByANon_governor() external {
    // it reverts
    vm.startPrank(alice);
    vm.expectRevert();
    wrapper.setDefaultWrapper(address(uniWrapper));
    vm.stopPrank();
  }

  modifier whenCalledWithAPairOfTokens() {
    _;
  }

  function test_GetWrapperWhenAPairWrapperIsInputted() external whenCalledWithAPairOfTokens {
    // it returns the pair wrapper
    vm.startPrank(governor);
    wrapper.setPairWrapper(address(weth), address(dai), address(sushiWrapper));
    wrapper.getWrapper(address(weth), address(dai));
    vm.stopPrank();
  }

  function test_GetWrapperWhenATokenWrapperIsInputted() external whenCalledWithAPairOfTokens {
    // it returns the token wrapper
    vm.startPrank(governor);
    wrapper.setTokenWrapper(address(dai), address(curveWrapper));
    wrapper.getWrapper(address(dai), address(weth));
    vm.stopPrank();
  }

  function test_GetWrapperWhenNoWrapperIsInputted() external whenCalledWithAPairOfTokens {
    // it returns the default wrapper Wrapper::getAmountOut
    vm.startPrank(governor);
    wrapper.setDefaultWrapper(address(sushiWrapper));
    wrapper.getWrapper(address(0), address(0));
    vm.stopPrank();
  }

     function test_GetBestAmountOutWhenAPairWrapperIsSet() external whenCalledWithAPair {
        // it returns the best amount out
        vm.startPrank(governor);
        wrapper.setDefaultWrapper(address(chainlink2));
        wrapper.setPairWrapper(address(weth), address(dai), address(sushiWrapper));
        wrapper.getBestAmountOut(address(weth), address(dai), 1e18);
        vm.stopPrank();
    }

    function test_GetBestAmountOutWhenATokenWrapperIsSet() external whenCalledWithAPair {
        // it returns the best amount out
        vm.startPrank(governor);
        wrapper.setDefaultWrapper(address(chainlink2));
        wrapper.setTokenWrapper(address(weth), address(uniWrapper));
        wrapper.getBestAmountOut(address(weth), address(dai), 1e18);
        vm.stopPrank();
    }

    // function test_GetBestAmountOutWhenNoWrapperIsSet() external whenCalledWithAPair {
    //     // it returns the best amount out
    // }

    function test_GetBestAmountOutWhenCalledWithAnInvalidPair() external {
        // it reverts
        vm.startPrank(governor);
        vm.expectRevert();
        wrapper.getBestAmountOut(address(0), address(0), 1e18);
        vm.stopPrank();
    }

  modifier whenCalledWithAPair() {
    _;
  }

  // function test_GetWrapperWhenAPairWrapperIsSet() external whenCalledWithAPair {
  //   // it returns the amount out
  // }

  // function test_GetWrapperWhenATokenWrapperIsSet() external whenCalledWithAPair {
  //   // it returns the amount out
  // }

  // function test_GetWrapperWhenNoWrapperIsSet() external whenCalledWithAPair {
  //   // it returns the amount out
  // }

  // function test_GetWrapperWhenCalledWithAnInvalidPair() external {
  //   // it reverts
  // }
}
