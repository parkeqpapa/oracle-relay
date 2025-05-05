// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

interface IOneInchRouter {
  type OracleType is uint8;

  error ArraysLengthMismatch();
  error ConnectorAlreadyAdded();
  error InvalidOracleTokenKind();
  error OracleAlreadyAdded();
  error SameTokens();
  error TooBigThreshold();
  error UnknownConnector();
  error UnknownOracle();

  event ConnectorAdded(address connector);
  event ConnectorRemoved(address connector);
  event MultiWrapperUpdated(address multiWrapper);
  event OracleAdded(address oracle, OracleType oracleType);
  event OracleRemoved(address oracle, OracleType oracleType);
  event OwnershipTransferred(address indexed previousOwner, address indexed newOwner);

  function addConnector(
    address connector
  ) external;
  function addOracle(address oracle, OracleType oracleKind) external;
  function connectors() external view returns (address[] memory allConnectors);
  function getRate(address srcToken, address dstToken, bool useWrappers) external view returns (uint256 weightedRate);
  function getRateToEth(address srcToken, bool useSrcWrappers) external view returns (uint256 weightedRate);
  function getRateToEthWithCustomConnectors(
    address srcToken,
    bool useSrcWrappers,
    address[] memory customConnectors,
    uint256 thresholdFilter
  ) external view returns (uint256 weightedRate);
  function getRateToEthWithThreshold(
    address srcToken,
    bool useSrcWrappers,
    uint256 thresholdFilter
  ) external view returns (uint256 weightedRate);
  function getRateWithCustomConnectors(
    address srcToken,
    address dstToken,
    bool useWrappers,
    address[] memory customConnectors,
    uint256 thresholdFilter
  ) external view returns (uint256 weightedRate);
  function getRateWithThreshold(
    address srcToken,
    address dstToken,
    bool useWrappers,
    uint256 thresholdFilter
  ) external view returns (uint256 weightedRate);
  function multiWrapper() external view returns (address);
  function oracles() external view returns (address[] memory allOracles, OracleType[] memory oracleTypes);
  function owner() external view returns (address);
  function removeConnector(
    address connector
  ) external;
  function removeOracle(address oracle, OracleType oracleKind) external;
  function renounceOwnership() external;
  function setMultiWrapper(
    address _multiWrapper
  ) external;
  function transferOwnership(
    address newOwner
  ) external;
}
