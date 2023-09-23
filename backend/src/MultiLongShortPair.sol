// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "forge-std/Test.sol";

import {LongShortPairCreator} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPairCreator.sol";
import {LongShortPair} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPair.sol";
import {LongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LongShortPairFinancialProductLibrary.sol";
import {LinearLongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LinearLongShortPairFinancialProductLibrary.sol";
import {FinderInterface} from "UMA/packages/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import {TokenFactory} from "UMA/packages/core/contracts/financial-templates/common/TokenFactory.sol";
import {IERC20Standard} from "UMA/packages/core/contracts/common/interfaces/IERC20Standard.sol";
import {UniswapV3Wrapper} from "./UniswapV3Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

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

contract MultiLongShortPair is Test {
	using SafeERC20 for IERC20;

	uint256 constant PERIOD_LENGTH = 120 days;

	struct FuturePeriod {
		LongShortPair lsp;
		address pool;
		uint256 startTimestamp;
	}

	bytes32 public name;
	mapping(uint32 => FuturePeriod) public futures;
	uint32 public newestFutureId = 0;

	UniswapV3Wrapper uniswapV3Wrapper;
	LinearLongShortPairFinancialProductLibrary settlementType;
	FinderInterface finder;
	TokenFactory tokenFactory;
	LongShortPairCreator lspCreator;
	LongShortPairCreator.CreatorParams lspParams;

	constructor(bytes32 _name, address _collateral, address _uniswapV3Wrapper, address _finder) {
		name = _name;
		uniswapV3Wrapper = UniswapV3Wrapper(_uniswapV3Wrapper);
		require(address(uniswapV3Wrapper) != address(0), "Invalid uniswap wrapper");

		settlementType = new LinearLongShortPairFinancialProductLibrary();
		require(address(settlementType) != address(0), "Invalid settlement type");
		finder = FinderInterface(_finder);
		require(address(finder) != address(0), "Invalid finder");
		tokenFactory = new TokenFactory();
		require(address(tokenFactory) != address(0), "Invalid token factory");
		lspCreator = new LongShortPairCreator(finder, tokenFactory, address(0));
		require(address(lspCreator) != address(0), "Invalid lsp creator");
		lspParams = LongShortPairCreator.CreatorParams({
			pairName: "",
			expirationTimestamp: 0,
			collateralPerPair: 0,
			priceIdentifier: bytes32("TOKEN_PRICE"),
			enableEarlyExpiration: true,
			longSynthName: "",
			longSynthSymbol: "",
			shortSynthName: "",
			shortSynthSymbol: "",
			collateralToken: IERC20Standard(_collateral),
			financialProductLibrary: settlementType,
			customAncillaryData: bytes(""),
			proposerReward: 100000,
			optimisticOracleLivenessTime: 100000,
			optimisticOracleProposerBond: 100000
		});

		_newFuturePeriod();
	}

	function printLspParams() public view 
	{
		console.log(lspParams.pairName);
		console.log(lspParams.expirationTimestamp);
		console.log(lspParams.collateralPerPair);
		console.log(string(abi.encodePacked("longSynthName: ", lspParams.longSynthName)));
		console.log(string(abi.encodePacked("longSynthSymbol: ", lspParams.longSynthSymbol)));
		console.log(string(abi.encodePacked("shortSynthName: ", lspParams.shortSynthName)));
		console.log(string(abi.encodePacked("shortSynthSymbol: ", lspParams.shortSynthSymbol)));
		console.log(string(abi.encodePacked("customAncillaryData: ", lspParams.customAncillaryData)));
	}

	function setLspParams() internal {
		string memory strId = Strings.toString(newestFutureId);
		lspParams.pairName = string(abi.encodePacked(name, strId));
		lspParams.expirationTimestamp = uint64(block.timestamp + PERIOD_LENGTH);
		lspParams.collateralPerPair = 1;
		lspParams.longSynthName = string(abi.encodePacked(name, "LONG", strId));
		lspParams.longSynthSymbol = string(abi.encodePacked(name, "LONG", strId));
		lspParams.shortSynthName = string(abi.encodePacked(name, "SHORT", strId));
		lspParams.shortSynthSymbol = string(abi.encodePacked(name, "SHORT", strId));
		// @todo edit for proper UMA resolvement
		lspParams.customAncillaryData = abi.encodePacked(strId);
		// printLspParams();
	}

	function _newFuturePeriod() internal {
		newestFutureId++;
		setLspParams();

		LongShortPair lsp = LongShortPair(lspCreator.createLongShortPair(lspParams));
		require(address(lsp) != address(0), "Failed to create lsp");
		address pool = uniswapV3Wrapper.createPool(address(lsp.longToken()), address(lsp.shortToken()));
		require(pool != address(0), "Failed to create pool");

		futures[newestFutureId] = FuturePeriod({
			lsp: lsp,
			pool: pool,
			startTimestamp: block.timestamp
		});
	}

	function newFuturePeriod() public {
		require(block.timestamp > futures[newestFutureId].startTimestamp + PERIOD_LENGTH - 30 days, "Too early to create new period");
		_newFuturePeriod();
	}

	function cheatNewFuturePeriod() public {
		_newFuturePeriod();
	}

	function getLsp(uint32 periodId) public view returns (LongShortPair lsp) {
		require (periodId <= newestFutureId, "Invalid period id");
		return futures[periodId].lsp;
	}

	function getPool(uint32 periodId) public view returns (address) {
		return futures[periodId].pool;
	}

	function getNewestLsp() public view returns (LongShortPair lsp) {
		return futures[newestFutureId].lsp;
	}
}