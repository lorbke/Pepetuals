// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// author: saucepoint
// run with a mainnet --fork-url such as:
//   forge test --fork-url https://rpc.ankr.com/eth

import "forge-std/Test.sol";

// temporary interface for minting USDC
// should be implemented more extensively, and organized somewhere
interface IUSDC {
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
}

contract USDCTest is Test {
    // USDC contract address on mainnet
    IUSDC usdc = IUSDC(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);

    function setUp() public {
        // spoof .configureMinter() call with the master minter account
        vm.prank(usdc.masterMinter());
        // allow this test contract to mint USDC
        usdc.configureMinter(address(this), type(uint256).max);
        
        // mint $1000 USDC to the test contract (or an external user)
        usdc.mint(address(this), 1000e6);
    }

    function testBalance() public {
        // verify the test contract has $1000 USDC
        uint256 balance = usdc.balanceOf(address(this));
        assertEq(balance, 1000e6);
    }
}