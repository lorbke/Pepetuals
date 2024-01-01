## CREATED FOR ETHGLOBAL NEW YORK

https://ethglobal.com/showcase/pepetuals-kyyw9

<img width="398" alt="image" src="https://github.com/patrick-hacks/Pepetuals/assets/72362902/da1f8288-6a7b-4b89-98f1-6e168b252374">

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
The frontend is built in multiple frameworks. The main underlying framework is React. The main components are build with [Near](https://near.org/) and deployed on their testnet ([LSC Component](https://test.near.org/paulg00.testnet/widget/LSC.Main),[LSP Compoennt](https://test.near.org/paulg00.testnet/widget/LSP.Main)). These two components use the bootstrap framework for styling. For renderening of these components a gateway in [Next.js](https://nextjs.org) was created. This gateway uses tailwind navigation components and for the basic website styling, but uses bootstrap for the Near components.
With this concept anyone who would like to implement our service can add our Near Widget wo their gateway/website.
The two main components are structured in the following way:
1. The LSC (Long/Short Converter) component to swap your USDC funds to a future/perpetular future.
2. The LSP (Long/Short Positions) component to show all of your current positions youre holding.

# Deploy

To test it yourself some solidity versions in the uniswap contracts have to be changed from =0.7.6 to >=0.7.6
NoDelegateCall.sol
UniswapV3Factory.sol
UniswapV3PoolDeployer.sol
lib/uniswapv3-periphery/contracts/base/LiquidityManagement.sol (=0.7.6)
lib/uniswapv3-periphery/contracts/libraries/CallbackValidation.sol (=0.7.6)
lib/uniswapv3-periphery/contracts/interfaces/external/IWETH9.sol (=0.7.6)


Some tests aren't fully implemented and are expected to fail.
