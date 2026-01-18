# OracleLib
[Git Source](https://github.com/andresf2448/DeFi-Foundry/blob/0f18a12c834a67e2d8118a557739f26594b1605a/src/libraries/OracleLib.sol)

**Title:**
OracleLib

**Author:**
Patrick Collins

This library is used to check the Chainlink Oracle for stale data.
If a price is stale, functions will revert, and render the DSCEngine unusable - this is by design.
We want the DSCEngine to freeze if prices become stale.
So if the Chainlink network explodes and you have a lot of money locked in the protocol... too bad.


## State Variables
### TIMEOUT

```solidity
uint256 private constant TIMEOUT = 3 hours
```


## Functions
### staleCheckLatestRoundData


```solidity
function staleCheckLatestRoundData(AggregatorV3Interface pricefeed)
    public
    view
    returns (uint80, int256, uint256, uint256, uint80);
```

## Errors
### OracleLib__StalePrice

```solidity
error OracleLib__StalePrice();
```

