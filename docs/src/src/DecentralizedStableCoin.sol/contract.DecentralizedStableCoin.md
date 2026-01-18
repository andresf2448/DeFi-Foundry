# DecentralizedStableCoin
[Git Source](https://github.com/andresf2448/DeFi-Foundry/blob/0f18a12c834a67e2d8118a557739f26594b1605a/src/DecentralizedStableCoin.sol)

**Inherits:**
ERC20Burnable, Ownable


## Functions
### constructor


```solidity
constructor() ERC20("DecentralizedStableCoin", "DSC");
```

### burn


```solidity
function burn(uint256 _amount) public override onlyOwner;
```

### mint


```solidity
function mint(address _to, uint256 _amount) external onlyOwner returns (bool);
```

## Errors
### DecentralizedStableCoin__MustBeMoreThanZero

```solidity
error DecentralizedStableCoin__MustBeMoreThanZero();
```

### DecentralizedStableCoin__BurnAmountExceedsBalance

```solidity
error DecentralizedStableCoin__BurnAmountExceedsBalance();
```

### DecentralizedStableCoin__NotZeroAddress

```solidity
error DecentralizedStableCoin__NotZeroAddress();
```

