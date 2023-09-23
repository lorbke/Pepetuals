// SPDX-License-Identifier: MIT-License
pragma solidity ^0.8.0;



import {Test, console2} from "forge-std/Test.sol";
import {LongShortPairCreator} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPairCreator.sol";
import {LongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LongShortPairFinancialProductLibrary.sol";
import {LinearLongShortPairFinancialProductLibrary} from "UMA/packages/core/contracts/financial-templates/common/financial-product-libraries/long-short-pair-libraries/LinearLongShortPairFinancialProductLibrary.sol";
import {FinderInterface} from "UMA/packages/core/contracts/data-verification-mechanism/interfaces/FinderInterface.sol";
import {TokenFactory} from "UMA/packages/core/contracts/financial-templates/common/TokenFactory.sol";
import {IERC20Standard} from "UMA/packages/core/contracts/common/interfaces/IERC20Standard.sol";

contract LongShortPairCreatorTest is Test {
	uint256 gnosis_mainnet_fork;

	LongShortPairCreator public lspCreator ;
	LinearLongShortPairFinancialProductLibrary public settlementContract = new LinearLongShortPairFinancialProductLibrary();
	FinderInterface finder = FinderInterface(0xE60dBa66B85E10E7Fd18a67a6859E241A243950e);
	address public lsp_contract_address;

	address public gnosis_mainnet_usdc = 0x07865c6E87B9F70255377e024ace6630C1Eaa37F;



	function setUp() public {
		gnosis_mainnet_fork = vm.createFork(vm.envString("GOERLI_RPC_URL"));
		assertEq(gnosis_mainnet_usdc, 0x07865c6E87B9F70255377e024ace6630C1Eaa37F);
		vm.selectFork(gnosis_mainnet_fork);
		assertEq(vm.activeFork(), gnosis_mainnet_fork);

		TokenFactory tokenFactory = new TokenFactory();
		address timer = address(0);
		lspCreator = new LongShortPairCreator(finder, tokenFactory, timer);
	}

	function test_createLongShortPair() public {
		LongShortPairCreator.CreatorParams memory params =  LongShortPairCreator.CreatorParams({
			pairName: "test",
			expirationTimestamp: 1703977200,
			collateralPerPair: 100,
			priceIdentifier: bytes32("TOKEN_PRICE"),
			enableEarlyExpiration: false,
			longSynthName: "test",
			longSynthSymbol: "test",
			shortSynthName: "test",
			shortSynthSymbol: "test",
			collateralToken: IERC20Standard(gnosis_mainnet_usdc),
			financialProductLibrary: settlementContract,
			customAncillaryData: bytes("this is a test"),
			proposerReward: 0,
			optimisticOracleLivenessTime: 100000,
			optimisticOracleProposerBond: 0
		});
		lsp_contract_address = lspCreator.createLongShortPair(params);
	}
}