// SPDX-License-Identifier: MIT
pragma solidity >=0.7.6;
// pragma experimental ABIEncoderV2;

// import "forge-std/Test.sol";
// import "../src/LiquidityExamples.sol"; // path to your LiquidityExamples contract

// contract LiquidityExamplesTest is Test {
//     LiquidityExamples liquidityExample;

// 	address public constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
// 	address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
//     address public constant POOL = 0x28cee28a7C4b4022AC92685C07d2f33Ab1A0e122;

// 	IERC20 public uni = IERC20(UNI);
// 	IERC20 public weth = IERC20(WETH);

// 	function fillUp() public {
// 		address self = address(this);
// 		vm.prank(UNI);
// 		uni.transfer(self, 10000e6);
// 		vm.prank(WETH);
// 		weth.transfer(self, 10000e6);

// 		weth.transfer(address(liquidityExample), 1000e6);
// 		uni.transfer(address(liquidityExample), 1000e6);

// 		assertEq(self, address(this));
// 		// console.log(uni.balanceOf(self));
// 		// console.log(weth.balanceOf(self));
//     }

//     function setUp() public {
// 		uint256 fork = vm.createFork(vm.envString("RPC_URL"));
// 		vm.selectFork(fork);

// 		liquidityExample = new LiquidityExamples();

// 		fillUp();
// 	}

//     function testMintNewPosition() public {
//         // Mint a new position
//         (uint _tokenId, uint128 liquidity, uint amount0, uint amount1) = liquidityExample.mintNewPosition();

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

//     function testOnERC721Received() public {
//         // Mint a new position
//         (uint _tokenId, , , ) = liquidityExample.mintNewPosition();

//         // Mock the operator to send the token
//         address operator = address(this);

//         bytes4 received = liquidityExample.onERC721Received(operator, address(0), _tokenId, "");

//         // Validate if ERC721 received
//         assertEq(received, liquidityExample.onERC721Received.selector, "ERC721 not received properly");
//     }

//     function testDepositDetails() public {
//         // Mint a new position
//         (uint _tokenId, , , ) = liquidityExample.mintNewPosition();

//         // Retrieve the deposit details
//         LiquidityExamples.Deposit memory deposit = liquidityExample.getDeposit(_tokenId);

//         assertEq(deposit.owner, address(this), "Owner mismatch");
//         assertNotEq(deposit.liquidity, 0, "Liquidity should not be zero");
//     }
// }