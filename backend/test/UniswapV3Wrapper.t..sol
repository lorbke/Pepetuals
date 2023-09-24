// // SPDX-License-Identifier: MIT
// pragma solidity >=0.7.6;
// pragma experimental ABIEncoderV2;

// import "forge-std/Test.sol";
// import "../src/UniswapV3Wrapper.sol"; // path to your LiquidityExamples contract
// import "../src/MultiLongShortPair.sol";
// import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
// import {LongShortPair} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPair.sol";
// import {IUniswapV3Factory} from "uniswapv3-core/contracts/interfaces/IUniswapV3Factory.sol";
// import {ExpandedIERC20} from "UMA/packages/core/contracts/common/interfaces/ExpandedIERC20.sol";


// contract UniswapV3WrapperTest is Test {
// 	address public constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
// 	address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
//     address public constant POOL = 0x28cee28a7C4b4022AC92685C07d2f33Ab1A0e122;
// 	address public constant FACTORY = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
// 	address public constant MANAGER = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;
// 	address public constant FINDER = 0xE60dBa66B85E10E7Fd18a67a6859E241A243950e;

//     UniswapV3Wrapper public uniswapV3Wrapper;
// 	IUniswapV3Factory public factory;
// 	MultiLongShortPair public mlsp;
// 	LongShortPair public lsp;

// 	IERC20 public uni = IERC20(UNI);
// 	IERC20 public weth = IERC20(WETH);

// 	address lpPool;
// 	address collatPoolLong;
// 	address collatPoolShort;
// 	address long;
// 	address short;

// 	ExpandedIERC20 public longToken;
// 	ExpandedIERC20 public shortToken;

// 	function fillUp() public {
// 		address self = address(this);
// 		vm.prank(UNI);
// 		uni.transfer(self, 10000e6);
// 		vm.prank(WETH);
// 		weth.transfer(self, 10000e6);

// 		weth.transfer(address(uniswapV3Wrapper), 1000e6);
// 		uni.transfer(address(uniswapV3Wrapper), 1000e6);

// 		assertEq(self, address(this));
// 		// console.log(uni.balanceOf(self));
// 		// console.log(weth.balanceOf(self));
//     }

//     function setUp() public {
// 		uint256 fork = vm.createFork(vm.envString("RPC_URL"));
// 		vm.selectFork(fork);

// 		uniswapV3Wrapper = new UniswapV3Wrapper(FACTORY, WETH, MANAGER);
// 		factory = IUniswapV3Factory(FACTORY);

// 		mlsp = new MultiLongShortPair(bytes32("TEST"), address(WETH), address(uniswapV3Wrapper), FINDER);
// 		lsp = mlsp.getLsp(1);
// 		longToken = lsp.longToken();
// 		shortToken = lsp.shortToken();
// 		long = address(longToken);
// 		short = address(shortToken);



// 		fillUp();
// 	}

// 	function testRealPoolProvideLiquidity() public {
// 		TransferHelper.safeApprove(UNI, address(uniswapV3Wrapper), 1000e6);
// 		TransferHelper.safeApprove(WETH, address(uniswapV3Wrapper), 1000e6);
// 		(uint _tokenId, uint128 liquidity, uint amount0, uint amount1) = uniswapV3Wrapper.provideLiquidity(UNI, WETH, 1000e6, 1000e6);

// 		console.log("results: ");
// 		console.log(_tokenId);
// 		console.log(liquidity);
// 		console.log(amount0);
// 		console.log(amount1);

// 		// Verify if liquidity is as expected
// 		assertNotEq(liquidity, 0, "Liquidity should not be zero");

// 		// Verify if tokenId is as expected
// 		assertNotEq(_tokenId, 0, "Token Id should not be zero");
// 	}

// 	function testCreateLpAndCollateralPools() public {
// 		(lpPool, collatPoolLong, collatPoolShort) = uniswapV3Wrapper.createLpAndCollateralPools(long, short, WETH);

// 		console.log(lpPool);
// 		console.log(collatPoolLong);
// 		console.log(collatPoolShort);

// 		assertEq(lpPool, factory.getPool(long, short, 100));
// 		assertEq(collatPoolLong, factory.getPool(long, WETH, 100));
// 		assertEq(collatPoolShort, factory.getPool(short, WETH, 100));

// 		vm.roll(1000);
// 	}

//     function testProvideLiquidity() public {
// 		TransferHelper.safeApprove(long, address(uniswapV3Wrapper), 1000e6);
// 		TransferHelper.safeApprove(short, address(uniswapV3Wrapper), 1000e6);
//         (uint _tokenId, uint128 liquidity, uint amount0, uint amount1) = uniswapV3Wrapper.provideLiquidity(long, short, 1000e6, 1000e6);

// 		console.log("results: ");
// 		console.log(_tokenId);
// 		console.log(liquidity);
// 		console.log(amount0);
// 		console.log(amount1);

//         // Verify if liquidity is as expected
//         assertNotEq(liquidity, 0, "Liquidity should not be zero");

//         // Verify if tokenId is as expected
//         assertNotEq(_tokenId, 0, "Token Id should not be zero");
//     }
// }