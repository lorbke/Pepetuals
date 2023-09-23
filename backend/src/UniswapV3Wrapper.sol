// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LongShortPairCreator} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPairCreator.sol";
import {LongShortPair} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPair.sol";
import {LongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LongShortPairFinancialProductLibrary.sol";
import {LinearLongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LinearLongShortPairFinancialProductLibrary.sol";
import {FinderInterface} from "UMA/packages/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import {TokenFactory} from "UMA/packages/core/contracts/financial-templates/common/TokenFactory.sol";
import {IERC20Standard} from "UMA/packages/core/contracts/common/interfaces/IERC20Standard.sol";
import {PoolInitializer} from "uniswapv3-periphery/contracts/base/PoolInitializer.sol";
import {PeripheryImmutableState} from "uniswapv3-periphery/contracts/base/PeripheryImmutableState.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

import {IUniswapV3Pool} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';

// @todo remove
// struct CreatorParams {
//     string pairName;
//     uint64 expirationTimestamp;
//     uint256 collateralPerPair;
//     bytes32 priceIdentifier;
//     bool enableEarlyExpiration;
//     string longSynthName;
//     string longSynthSymbol;
//     string shortSynthName;
//     string shortSynthSymbol;
//     IERC20Standard collateralToken;
//     LongShortPairFinancialProductLibrary financialProductLibrary;
//     bytes customAncillaryData;
//     uint256 proposerReward;
//     uint256 optimisticOracleLivenessTime;
//     uint256 optimisticOracleProposerBond;
// }

contract UniswapV3Wrapper is PoolInitializer {
	using SafeERC20 for IERC20;

	uint24 constant FEE = 3000;
	// uint160 constant SQRT_PRICE = uint160(sqrt(1) * 2 ** 96);

	constructor(address _uniswapV3Factory, address _WETH9) PeripheryImmutableState(_uniswapV3Factory, _WETH9) {
	}

	function sqrt(uint y) internal pure returns (uint z) {
		if (y > 3) {
			z = y;
			uint x = y / 2 + 1;
			while (x < z) {
				z = x;
				x = (y / x + x) / 2;
			}
		} else if (y != 0) {
			z = 1;
		}
	}

	function createPool(address token0, address token1) public returns (address pool) {
		if (token0 > token1) {
			return this.createAndInitializePoolIfNecessary(token1, token0, FEE, uint160(sqrt(1) * 2 ** 96));
		}
		return this.createAndInitializePoolIfNecessary(token0, token1, FEE, uint160(sqrt(1) * 2 ** 96));

	}

	// positive amount = exact input, negative amount = exact output
	function sellToken(address pool, bool longForShort, int256 amount) public {
		IUniswapV3Pool uniswapPool = IUniswapV3Pool(pool);

		uniswapPool.swap(msg.sender, longForShort, amount, 0, bytes(""));
	}
}