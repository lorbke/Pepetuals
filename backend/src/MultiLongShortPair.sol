// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {LongShortPairCreator} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPairCreator.sol";
import {LongShortPair} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPair.sol";
import {LongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LongShortPairFinancialProductLibrary.sol";
import {LinearLongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LinearLongShortPairFinancialProductLibrary.sol";
import {FinderInterface} from "UMA/packages/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import {TokenFactory} from "UMA/packages/core/contracts/financial-templates/common/TokenFactory.sol";
import {IERC20Standard} from "UMA/packages/core/contracts/common/interfaces/IERC20Standard.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

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

contract MultiLongShortPair {
	using SafeERC20 for IERC20;

	uint256 constant PERIOD_LENGTH = 120 days;

	struct FuturePeriod {
		LongShortPair lsp;
		uint256 startTimestamp;
	}

	bytes32 public name;
	mapping(uint32 => FuturePeriod) public futures;
	uint32 public newestFutureId = 0;

	LinearLongShortPairFinancialProductLibrary settlementType;
	FinderInterface finder;
	TokenFactory tokenFactory;
	LongShortPairCreator lspCreator;
	LongShortPairCreator.CreatorParams lspParams;

	constructor(bytes32 _name, IERC20Standard _collateral) {
		name = _name;

		settlementType = new LinearLongShortPairFinancialProductLibrary();
		finder = FinderInterface(0xE60dBa66B85E10E7Fd18a67a6859E241A243950e);
		tokenFactory = new TokenFactory();
		lspCreator = new LongShortPairCreator(finder, tokenFactory, address(0));
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
			collateralToken: _collateral,
			financialProductLibrary: settlementType,
			customAncillaryData: bytes(""),
			proposerReward: 100000,
			optimisticOracleLivenessTime: 100000,
			optimisticOracleProposerBond: 100000
		});

		newFuturePeriod();
		newestFutureId--;
	}

	function setLspParams() internal {
		lspParams.pairName = string(abi.encodePacked(name, newestFutureId));
		lspParams.expirationTimestamp = uint64(block.timestamp + PERIOD_LENGTH);
		lspParams.collateralPerPair = 100;
		lspParams.longSynthName = string(abi.encodePacked(name, "LONG", newestFutureId));
		lspParams.longSynthSymbol = string(abi.encodePacked(name, "LONG", newestFutureId));
		lspParams.shortSynthName = string(abi.encodePacked(name, "SHORT", newestFutureId));
		lspParams.shortSynthSymbol = string(abi.encodePacked(name, "SHORT", newestFutureId));
		// @todo edit for proper UMA resolvement
		lspParams.customAncillaryData = abi.encodePacked(newestFutureId);
	}

	function _newFuturePeriod() internal {
		newestFutureId++;
		setLspParams();
		futures[newestFutureId] = FuturePeriod({
			lsp: LongShortPair(lspCreator.createLongShortPair(lspParams)),
			startTimestamp: block.timestamp
		});
	}

	function newFuturePeriod() public {
		require(block.timestamp > futures[newestFutureId].startTimestamp + PERIOD_LENGTH - 30 days, "Too early to create new period");
		_newFuturePeriod();
	}

	function getLsp(uint32 futureId) public view returns (LongShortPair lsp) {
		return futures[futureId].lsp;
	}

	function getNewestLsp() public view returns (LongShortPair lsp) {
		return futures[newestFutureId].lsp;
	}
}