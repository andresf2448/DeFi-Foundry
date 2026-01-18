# DSCEngine
[Git Source](https://github.com/andresf2448/DeFi-Foundry/blob/0f18a12c834a67e2d8118a557739f26594b1605a/src/DSCEngine.sol)

**Inherits:**
ReentrancyGuard


## State Variables
### ADDITIONAL_FEED_PRECISION

```solidity
uint256 private constant ADDITIONAL_FEED_PRECISION = 1e10
```


### PRECISION

```solidity
uint256 private constant PRECISION = 1e18
```


### LIQUIDATION_THRESHOLD

```solidity
uint256 private constant LIQUIDATION_THRESHOLD = 50
```


### LIQUIDATION_PRECISION

```solidity
uint256 private constant LIQUIDATION_PRECISION = 100
```


### MIN_HEALTH_FACTOR

```solidity
uint256 private constant MIN_HEALTH_FACTOR = 1e18
```


### LIQUIDATION_BONUS

```solidity
uint256 private constant LIQUIDATION_BONUS = 10
```


### sPriceFeeds

```solidity
mapping(address token => address priceFeed) private sPriceFeeds
```


### sCollateralDeposited

```solidity
mapping(address user => mapping(address token => uint256 amount)) private sCollateralDeposited
```


### sdscMinted

```solidity
mapping(address user => uint256 amountDscMinted) private sdscMinted
```


### sCollateralTokens

```solidity
address[] private sCollateralTokens
```


### I_DSC

```solidity
DecentralizedStableCoin private immutable I_DSC
```


## Functions
### moreThanZero


```solidity
modifier moreThanZero(uint256 _amount) ;
```

### isAllowedToken


```solidity
modifier isAllowedToken(address _token) ;
```

### constructor


```solidity
constructor(address[] memory _tokenAdresses, address[] memory _priceFeedAddesses, address dscAddress) ;
```

### depositCollateralAndMintDsc


```solidity
function depositCollateralAndMintDsc(
    address _tokenCollateralAddress,
    uint256 _amountCollateral,
    uint256 _amountDscToMint
) external;
```

### depositCollateralAndMintDsc


```solidity
function depositCollateralAndMintDsc() external;
```

### depositCollateral


```solidity
function depositCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
    public
    moreThanZero(_amountCollateral)
    isAllowedToken(_tokenCollateralAddress)
    nonReentrant;
```

### redeemCollateralForDsc


```solidity
function redeemCollateralForDsc(
    address _tokenCollateralAddress,
    uint256 _amountCollateral,
    uint256 _amountDscToBurn
) external;
```

### redeemCollateral


```solidity
function redeemCollateral(address _tokenCollateralAddress, uint256 _amountCollateral)
    public
    moreThanZero(_amountCollateral)
    nonReentrant;
```

### mintDsc


```solidity
function mintDsc(uint256 _amountDscToMint) public moreThanZero(_amountDscToMint) nonReentrant;
```

### burnDsc


```solidity
function burnDsc(uint256 _amount) public moreThanZero(_amount);
```

### liquidate


```solidity
function liquidate(address _collateral, address _user, uint256 _debtToCover)
    external
    moreThanZero(_debtToCover)
    nonReentrant;
```

### getHealthFactor


```solidity
function getHealthFactor() external view;
```

### _burnDsc


```solidity
function _burnDsc(uint256 _amountDscToBurn, address _onBehalfOf, address _dscFrom) private;
```

### _redeemCollateral


```solidity
function _redeemCollateral(address _from, address _to, address _tokenCollateralAddress, uint256 _amountCollateral)
    private;
```

### _getAccountInformation


```solidity
function _getAccountInformation(address _user)
    private
    view
    returns (uint256 _totalDscMinted, uint256 _collateralValueInUsd);
```

### _calculateHealthFactor


```solidity
function _calculateHealthFactor(uint256 totalDscMinted, uint256 collateralValueInUsd)
    internal
    pure
    returns (uint256);
```

### _healthFactor


```solidity
function _healthFactor(address _user) private view returns (uint256);
```

### _revertIfHealthFactorIsBroken


```solidity
function _revertIfHealthFactorIsBroken(address _user) internal view;
```

### getTokenAmountFromUsd


```solidity
function getTokenAmountFromUsd(address _token, uint256 _usdAmountInWei) public view returns (uint256);
```

### getAccountCollateralValue


```solidity
function getAccountCollateralValue(address _user) public view returns (uint256 totalCollateralValueInUsd);
```

### getUsdValue


```solidity
function getUsdValue(address _token, uint256 _amount) public view returns (uint256);
```

### getAccountInformation


```solidity
function getAccountInformation(address _user)
    external
    view
    returns (uint256 totalDscMinted, uint256 collateralValueInUsd);
```

### getPrecision


```solidity
function getPrecision() external pure returns (uint256);
```

### getAdditionalFeedPrecision


```solidity
function getAdditionalFeedPrecision() external pure returns (uint256);
```

### getLiquidationThreshold


```solidity
function getLiquidationThreshold() external pure returns (uint256);
```

### getLiquidationBonus


```solidity
function getLiquidationBonus() external pure returns (uint256);
```

### getLiquidationPrecision


```solidity
function getLiquidationPrecision() external pure returns (uint256);
```

### getMinHealthFactor


```solidity
function getMinHealthFactor() external pure returns (uint256);
```

### getCollateralTokens


```solidity
function getCollateralTokens() external view returns (address[] memory);
```

### getDsc


```solidity
function getDsc() external view returns (address);
```

### getCollateralTokenPriceFeed


```solidity
function getCollateralTokenPriceFeed(address token) external view returns (address);
```

### getHealthFactor


```solidity
function getHealthFactor(address user) external view returns (uint256);
```

### getCollateralBalanceOfUser


```solidity
function getCollateralBalanceOfUser(address _user, address _token) external view returns (uint256);
```

## Events
### DSCEngine__CollateralDeposited

```solidity
event DSCEngine__CollateralDeposited(address indexed user, address indexed token, uint256 amount);
```

### DSCEngine__CollateralRedeemed

```solidity
event DSCEngine__CollateralRedeemed(
    address indexed redeemedFrom, address indexed redeemedTo, address indexed token, uint256 amount
);
```

## Errors
### DSCEngine__NeedsMoreThanZero

```solidity
error DSCEngine__NeedsMoreThanZero();
```

### DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength

```solidity
error DSCEngine__TokenAddressesAndPriceFeedAddressesMustBeSameLength();
```

### DSCEngine__NotAllowedToken

```solidity
error DSCEngine__NotAllowedToken();
```

### DSCEngine__TransferFailed

```solidity
error DSCEngine__TransferFailed();
```

### DSCEngine__BreaksHealthFactor

```solidity
error DSCEngine__BreaksHealthFactor(uint256 healthFactor);
```

### DSCEngine__MintFailed

```solidity
error DSCEngine__MintFailed();
```

### DSCEngine__HealthFactorOk

```solidity
error DSCEngine__HealthFactorOk();
```

### DSCEngine__HealthFactorNotImproved

```solidity
error DSCEngine__HealthFactorNotImproved();
```

