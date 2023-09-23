// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RollingPool.sol";
import "../src/MultiLongShortPair.sol";

contract FutureMock is ERC20 {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

    function mint(address account, uint256 amount) public {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public {
        _burn(account, amount);
    }
}

contract RollingPoolTest is Test {
    FutureMock public currency;
    MultiLongShortPair public lsp;
    RollingPool public pool;

    function setUp() public {
        currency = new FutureMock("asd", "asd");
        lsp = new MultiLongShortPair(currency);
        // PairToken asd = lsp.getActiveLong();
        // PairToken asd2 = lsp.activeFuture().longToken;
        // lsp.activeFuture().longToken.approve(address(this), 1000);
        // lsp.getActiveLong().approve(address(this), 1000);
        pool = new RollingPool(lsp);
        currency.mint(address(this), 100000);
        currency.approve(address(lsp), 10000);
        currency.approve(address(pool), 10000);
    }

    function testDeposit() public {
        assertEq(pool.previewDeposit(1000), 1000);

        lsp.mint(address(this), 0, 1000);
        lsp.activeFuture().longToken.approve(address(pool), 1000);
        pool.deposit(1000);

        assertEq(pool.previewDeposit(1000), 1000);
    }

    function testTooMuchInPool() public {
        lsp.mint(address(this), 0, 1000);
        lsp.activeFuture().longToken.approve(address(pool), 1000);
        pool.deposit(1000);

        lsp.mint(address(this), 0, 200);
        lsp.activeFuture().longToken.transfer(address(pool), 200);
        assertEq(pool.share().balanceOf(address(this)), 1000);

        lsp.mint(address(this), 0, 1000);
        lsp.activeFuture().longToken.approve(address(pool), 1000);
        pool.deposit(1000);
        assertEq(lsp.activeFuture().longToken.balanceOf(address(this)), 0);
        // pool.withdraw(1000);
        // assertEq(pool.poolToken().balanceOf(address(this)), 0);
        // assertEq(lsp.activeFuture().longToken.balanceOf(address(this)), 1200);
    }
}