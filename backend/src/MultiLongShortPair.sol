// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LongShortPairCreator} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPairCreator.sol";
import {LongShortPair} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPair.sol";
import {LongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LongShortPairFinancialProductLibrary.sol";
import {LinearLongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LinearLongShortPairFinancialProductLibrary.sol";
import {FinderInterface} from "UMA/packages/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import {TokenFactory} from "UMA/packages/core/contracts/financial-templates/common/TokenFactory.sol";
import {IERC20Standard} from "UMA/packages/core/contracts/common/interfaces/IERC20Standard.sol";
// import {UniswapV3Wrapper} from "./UniswapV3Wrapper.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./UniswapMock.sol";

contract MultiLongShortPair {
	using SafeERC20 for IERC20;

	/*------------------------------------------------------------------------------------*/
	/* 	DATA STRUCTURE                                                                    */
	/*------------------------------------------------------------------------------------*/

	uint256 constant PERIOD_LENGTH = 120 days;

	struct FuturePeriod {
		LongShortPair lsp;
		address poolLongShort;
		address poolLongCollat;
		address poolShortCollat;
		address poolLongShortMock;
		address poolLongCollatMock;
		address poolShortCollatMock;
		uint256 startTimestamp;
	}

	bytes32 public name;
	mapping(uint32 => FuturePeriod) public futures;
	uint32 public newestFutureId = 0;

	// UniswapV3Wrapper uniswapV3Wrapper;
	LinearLongShortPairFinancialProductLibrary settlementType;
	FinderInterface finder;
	TokenFactory tokenFactory;
	LongShortPairCreator lspCreator;
	LongShortPairCreator.CreatorParams lspParams;

	/*------------------------------------------------------------------------------------*/
	/* 	CONSTRUCTOR                                                                       */
	/*------------------------------------------------------------------------------------*/

	constructor(bytes32 _name, address _collateral, address _uniswapV3Wrapper, address _finder) {
		name = _name;

		// uniswapV3Wrapper = UniswapV3Wrapper(_uniswapV3Wrapper);
		// require(address(uniswapV3Wrapper) != address(0), "Invalid uniswap wrapper");
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
			collateralPerPair: 1,
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

	/*------------------------------------------------------------------------------------*/
	/* 	HELPER FUNCTIONS                                                                  */
	/*------------------------------------------------------------------------------------*/

	// function printLspParams() public view {
	// 	console.log(lspParams.pairName);
	// 	console.log(lspParams.expirationTimestamp);
	// 	console.log(lspParams.collateralPerPair);
	// 	console.log(string(abi.encodePacked("longSynthName: ", lspParams.longSynthName)));
	// 	console.log(string(abi.encodePacked("longSynthSymbol: ", lspParams.longSynthSymbol)));
	// 	console.log(string(abi.encodePacked("shortSynthName: ", lspParams.shortSynthName)));
	// 	console.log(string(abi.encodePacked("shortSynthSymbol: ", lspParams.shortSynthSymbol)));
	// 	console.log(string(abi.encodePacked("customAncillaryData: ", lspParams.customAncillaryData)));
	// }

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

		// (address poolLongShort, address poolLongCollat, address poolShortCollat) =
		// uniswapV3Wrapper.createLpAndCollateralPools(address(lsp.longToken()), address(lsp.shortToken()),
		// address(lspParams.collateralToken));
		// require(poolLongShort != address(0), "Failed to create long-short pool");
		// require(poolLongCollat != address(0), "Failed to create long-collateral pool");
		// require(poolShortCollat != address(0), "Failed to create short-collateral pool");
		UniswapMock mock = new UniswapMock(address(lsp.longToken()), address(lsp.shortToken()));
		UniswapMock mockl = new UniswapMock(address(lsp.longToken()), address(lspParams.collateralToken));
		UniswapMock mocks = new UniswapMock(address(lsp.longToken()), address(lspParams.collateralToken));

		address poolLongShortMock = address(mock);
		address poolLongCollatMock = address(mockl);
		address poolShortCollatMock = address(mocks);

		futures[newestFutureId] = FuturePeriod({
			lsp: lsp,
			poolLongShort: address(0),
			poolLongCollat: address(0),
			poolShortCollat: address(0),
			poolLongShortMock: poolLongShortMock,
			poolLongCollatMock: poolLongCollatMock,
			poolShortCollatMock:poolShortCollatMock,
			startTimestamp: block.timestamp
		});
	}

	/*------------------------------------------------------------------------------------*/
	/* 	EXTERNAL FUNCTIONS                                                                */
	/*------------------------------------------------------------------------------------*/

	function newFuturePeriod() public {
		require(block.timestamp > futures[newestFutureId].startTimestamp + PERIOD_LENGTH - 30 days, "Too early to create new period");
		_newFuturePeriod();
	}

	function cheatNewFuturePeriod() external {
		_newFuturePeriod();
	}

	function getLsp(uint32 periodId) external view returns (LongShortPair lsp) {
		require (periodId <= newestFutureId, "Invalid period id");
		return futures[periodId].lsp;
	}

	function getPoolLongShort(uint32 periodId) external view returns (address) {
		return futures[periodId].poolLongShortMock;
	}

	function getPoolLongCollat(uint32 periodId) external view returns (address) {
		return futures[periodId].poolLongCollat;
	}

	function getPoolShortCollat(uint32 periodId) external view returns (address) {
		return futures[periodId].poolShortCollat;
	}

	function getNewestLsp() external view returns (address lsp) {
		return address(futures[newestFutureId].lsp);
	}

	function getLongToken(uint32 periodId) external view returns (address token) {
		return address(futures[periodId].lsp.longToken());
	}

	function getShortToken(uint32 periodId) external view returns (address token) {
		return address(futures[periodId].lsp.shortToken());
	}

	function getNewestLongToken() external view returns (address token) {
		return address(futures[newestFutureId].lsp.longToken());
	}

	function getNewestPeriodId() external view returns (uint32) {
		return newestFutureId;
	}
}