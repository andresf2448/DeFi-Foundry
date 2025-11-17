// SPDX-License-Identifier: MIT

pragma solidity ^0.8.18;

import {DecentralizedStableCoin} from "./DecentralizedStableCoin.sol";
import {ReentrancyGuard} from "@openzepplin/contracts/security/ReentrancyGuard.sol";
import {IERC20} from "@openzepplin/contracts/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";

/*
 * @title DSCEngine
 * @author Andrés Velásquez
 *
 * The system is designed to be as minimal as possible, and have the tokens maintain a 1 token == $1 peg at all times.
 * This is a stablecoin with the properties:
 * - Exogenously Collateralized
 * - Dollar Pegged
 * - Algorithmically Stable
 *
 * It is similar to DAI if DAI had no governance, no fees, and was backed by only WETH and WBTC.
 *
 * Our DSC system should always be "overcollateralized". At no point, should the value of
 * all collateral < the $ backed value of all the DSC.
 *
 * @notice This contract is the core of the Decentralized Stablecoin system. It handles all the logic
 * for minting and redeeming DSC, as well as depositing and withdrawing collateral.
 * @notice This contract is based on the MakerDAO DSS system
 */

contract DSCEngine is ReentrancyGuard{
  // Errors
  error DSCEngine__NeedsMoreThanZero();
  error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
  error DSCEngine__NotAllowedToken();
  error DSCEngine__TransferFailed();
  error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
  error DSCEngine__MintFailed();

  // State Variables
  uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10;
  uint256 private constant PRECISION = 1e18;
  uint256 private constant LIQUIDATION_THRESHOLD = 50; // 200% overcollateralized
  uint256 private constant LIQUIDATION_PRECISION = 100;
  uint256 private constant MIN_HEALTH_FACTOR = 1;

  mapping(address token => address priceFeed) private sPriceFeeds; // tokenToPriceFeed
  mapping(address user => mapping(address token => uint256 amount)) private sCollateralDeposited; // user => token => amount
  mapping(address user => uint256 amountDscMinted) private sDscMinted;
  address[] private sCollateralTokens;

  DecentralizedStableCoin private immutable I_DSC;

  // Events
  event DSCEngine__CollateralDeposited(address indexed user, address indexed token, uint256 amount);
  event DSCEngine__CollateralRedeemed(address indexed user, address indexed token, uint256 indexed amount);

  // Modifiers
  modifier moreThanZero(uint256 amount) {
    if(amount == 0) {
      revert DSCEngine__NeedsMoreThanZero();
    }
    _;
  }

  modifier isAllowedToken(address token) {
    if(sPriceFeeds[token] == address(0)) {
      revert DSCEngine__NotAllowedToken();
    }
    _;
  }

  // Functions
  constructor(
    address[] memory tokenAddresses,
    address[] memory priceFeedAddresses,
    address dscAddress
  ) {
    // USD Price Feeds
    if(tokenAddresses.length != priceFeedAddresses.length) {
      revert DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
    }
    // For example ETH / USD, BTC / USD, MKR / USD, etc
    for(uint256 i = 0; i < tokenAddresses.length; i++) {
      sPriceFeeds[tokenAddresses[i]] = priceFeedAddresses[i];
      sCollateralTokens.push(tokenAddresses[i]);
    }
    I_DSC = DecentralizedStableCoin(dscAddress);
  }

  // External Functions
  /*
    * @param tokenCollateralAddress The address of the token to deposit as collateral
    * @param amountCollateral The amount of collateral to deposit
    * @param amountDscToMint The amount of descentralized stablecoin to mint
    * @notice This function deposits collateral and mints DSC in one transaction
    */
  function depositCollateralAndMinDsc(
    address tokenCollateralAddress,
    uint256 amountCollateral,
    uint256 amountDscToMint 
  ) external {
    depositCollateral((tokenCollateralAddress), amountCollateral);
    mintDsc(amountDscToMint);
  }

  /*
   * @param tokenCollateralAddress The address of the token to deposit as collateral
   * @param amountCollateral The amount of collateral to deposit
   */
  function depositCollateral(
    address tokenCollateralAddress,
    uint256 amountCollateral
  ) 
    public
    moreThanZero(amountCollateral)
    isAllowedToken(tokenCollateralAddress)
    nonReentrant
  {
    sCollateralDeposited[msg.sender][tokenCollateralAddress] += amountCollateral;
    emit DSCEngine__CollateralDeposited(msg.sender, tokenCollateralAddress, amountCollateral);
    bool success = IERC20(tokenCollateralAddress).transferFrom(msg.sender, address(this), amountCollateral);

    if(!success) {
      revert DSCEngine__TransferFailed();
    }
  }

  function redeemCollateralForDsc() external {}

  function redeemCollateral(
    address tokenCollateralAddress,
    uint256 amountCollateral
  )
    public
    moreThanZero(amountCollateral)
    nonReentrant
  {
    sCollateralDeposited[msg.sender][tokenCollateralAddress] -= amountCollateral;
    emit DSCEngine__CollateralRedeemed(msg.sender, tokenCollateralAddress, amountCollateral);

    //_calculateHealthFactor()
    bool success = IERC20(tokenCollateralAddress).transfer(msg.sender, amountCollateral);

    if(!success) {
      revert DSCEngine__TransferFailed();
    }
    _revertIfHealthFactorIsBroken(msg.sender);
  }

  function mintDsc(uint256 amountDscToMint) public moreThanZero(amountDscToMint) nonReentrant {
    sDscMinted[msg.sender] += amountDscToMint;
    _revertIfHealthFactorIsBroken(msg.sender);

    bool minted = I_DSC.mint(msg.sender, amountDscToMint);

    if(!minted) {
      revert DSCEngine__MintFailed();
    }
  }

  function burnDsc(uint256 amount)
    public
    moreThanZero(amount)
  {
    sDscMinted[msg.sender] -= amount;
    bool success = I_DSC.transferFrom(msg.sender, address(this), amount);

    if(!success) {
      revert DSCEngine__TransferFailed();
    }

    I_DSC.burn(amount);
    _revertIfHealthFactorIsBroken(msg.sender);
  }

  function liquidate() external {}

  function getHealthFactor() external view {}

  // Private & Internal View Functions
  function _getAccountInformation(address user) private view returns (uint256 totalDscMinted, uint256 collateralValueInUsd) {
    totalDscMinted = sDscMinted[user];
    collateralValueInUsd = getAccountCollateralValue(user);
  }

  function _healthFactor(address user) private view returns (uint256) {
    // total DSC Minted
    // total collateral VALUE
    (uint256 totalDscMinted, uint256 collateralValueInUsd) = _getAccountInformation(user);
    uint256 collateralAdjustedForThreshold = (collateralValueInUsd * LIQUIDATION_THRESHOLD) / LIQUIDATION_PRECISION;

    return (collateralAdjustedForThreshold * PRECISION) / totalDscMinted;
  }
  
  function _revertIfHealthFactorIsBroken(address user) internal view {
    uint256 userHealthFactor = _healthFactor(user);

    if(userHealthFactor < MIN_HEALTH_FACTOR) {
      revert DSCEngine__BreaksHealthFactor(userHealthFactor);
    }
  }

  // Public & External View Functions
  function getAccountCollateralValue(address user) public view returns (uint256 totalCollateralValueInUsd) {
    for(uint256 i = 0; i < sCollateralTokens.length; i++) {
      address token = sCollateralTokens[i];
      uint256 amount = sCollateralDeposited[user][token];
      totalCollateralValueInUsd += getUsdValue(token, amount);
    }

    return totalCollateralValueInUsd;
  }

  function getUsdValue(address token, uint256 amount) public view returns (uint256) {
    AggregatorV3Interface priceFeed = AggregatorV3Interface(sPriceFeeds[token]);
    (,int256 price,,,) = priceFeed.latestRoundData();

    return ((uint256(price) * ADDITIONAL_FEED_PRECISION) * amount) / PRECISION;
  }
}