# Pepetuals

This project is a new approach to perpetual onchain futures. There have been quite a few approaches in the past, but we believe that none of them match our idea, especially in terms of stability.

The presentation can be found here:
https://docs.google.com/presentation/d/1SnWZmQYaW7W_3zFY-c6oZT-BYV2DgJLPcIJjkJs1Hws/edit#slide=id.g282cbbbe77c_0_107

## Contracts

### MultiLongShortPair:
Deploys long short pairs for a given asset.
Manages the uniswap pools.

### RollingPool:
Deposit futures into the pool. They will automatically be converted into new shares towards the end of each period and can be withdrawn at any point.
Bots have to call startRollover as well as rollDeposit / rollWithdraw. As an incentive bonus tokens are given out.

### UniswapV3Wrapper:
Wrapper for the uniswap pool for more easy usage.

### ApiContract
Mainly used as a wrapper for easy usability from the frontend.


## Frontend:


# Deploy

To test it yourself some solidity versions in the uniswap contracts have to be changed from =0.7.6 to >=0.7.6
NoDelegateCall.sol
UniswapV3Factory.sol
UniswapV3PoolDeployer.sol
lib/uniswapv3-periphery/contracts/base/LiquidityManagement.sol (=0.7.6)
lib/uniswapv3-periphery/contracts/libraries/CallbackValidation.sol (=0.7.6)
lib/uniswapv3-periphery/contracts/interfaces/external/IWETH9.sol (=0.7.6)


Some tests aren't fully implemented and are expected to fail.