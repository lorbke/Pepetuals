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
        pool = new RollingPool(lsp);
    }

    function mintAproveLong(address account, uint256 amount, uint32 period) public {
        currency.mint(account, amount);
        currency.approve(address(lsp), amount);
        lsp.mint(account, period, amount);
        lsp.activeFuture().longToken.approve(address(pool), amount);
    }

    function startRoll(uint256 amount) public {
        vm.startPrank(address(1));
        mintAproveLong(address(1), amount, 0);
        pool.deposit(amount);
        vm.stopPrank();
        lsp.cheatForceNewPeriod();
        pool.startRollover();
    }

    function finishRoll(uint256 blockDuration) public {
        vm.roll(blockDuration);
        vm.startPrank(address(1));
        mintAproveLong(address(1), 10000, 1);
        lsp.activeFuture().longToken.approve(address(pool), 10000);  
        pool.rollWithdraw(10000);
        vm.stopPrank();
        assertEq(pool.rolling(), false);
    }

    function testDeposit() public {
        assertEq(pool.previewDeposit(1000), 1000);
        mintAproveLong(address(this), 1000, 0);
        pool.deposit(500);

        assertEq(pool.getFutureBalance(address(this)), 500);
    }

    function testTooMuchInPool() public {
        mintAproveLong(address(this), 2000, 0);
        pool.deposit(1000);
        lsp.activeFuture().longToken.transfer(address(pool), 200);
        assertEq(pool.share().balanceOf(address(this)), 1000);

        pool.redeem(1000);
        assertEq(lsp.activeFuture().longToken.balanceOf(address(this)), 1999);
    }

    function testRolloverDeposit() public {
        startRoll(10000);

        vm.roll(10000);
        mintAproveLong(address(this), 10000, 1);
        pool.rollDeposit(1000); 
        assertEq(lsp.getFutureToken(0, true).balanceOf(address(this)), 1100);
        assertEq(lsp.getFutureToken(1, true).balanceOf(address(this)), 9000);
    }

    function testRolloverWithdraw() public {
        startRoll(10000);

        vm.roll(10000);
        mintAproveLong(address(this), 10000, 1);
        pool.rollWithdraw(1100);
        assertEq(lsp.getFutureToken(0, true).balanceOf(address(this)), 1100);
        assertEq(lsp.getFutureToken(1, true).balanceOf(address(this)), 9000);
    }

    function testRolloverEnd() public {
        startRoll(10000);  
        vm.roll(10000);

        mintAproveLong(address(this), 10000, 1);
        pool.rollWithdraw(9999);  
        assertEq(pool.rolling(), true);
        pool.rollWithdraw(1);  
        assertEq(pool.rolling(), false);
    }

    function testRollingFundChange() public {
        mintAproveLong(address(this), 10000, 0);
        pool.deposit(10000);

        startRoll(0);
        finishRoll(10000);

        pool.redeem(pool.share().balanceOf(address(this)));
        assertEq(lsp.getFutureToken(1, true).balanceOf(address(this)), 9090);
        // pool.redeem(1000);
        // assertEq()
        // assertEq(pool.)
    }
}

