// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "forge-std/Test.sol";
import "../src/RollingPool.sol";
import "../src/MultiLongShortPair.sol";

interface IUSDC {
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
}

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
    FutureMock public collateral;
    MultiLongShortPair public mlsp;
    RollingPool public pool;
    address FINDER = 0xE60dBa66B85E10E7Fd18a67a6859E241A243950e;

    IUSDC usdc = IUSDC(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);
    function mint() public {
        vm.prank(usdc.masterMinter());
        usdc.configureMinter(address(this), type(uint256).max);
        usdc.mint(address(this), 1000e6);
    }

    function setUp() public {
        uint256 gnosis_mainnet_fork = vm.createFork(vm.envString("GOERLI_RPC_URL"));
		vm.selectFork(gnosis_mainnet_fork);

        mlsp = new MultiLongShortPair("asd", address(usdc), FINDER);
        pool = new RollingPool(mlsp);
    }

    function mintAproveLong(address account, uint256 amount, uint32 period) public {
        collateral.mint(account, amount);
        collateral.approve(address(mlsp), amount);
        mlsp.getLsp(period).create(amount);
        mlsp.getLsp(period).longToken().approve(address(pool), amount);
    }

    function startRoll(uint256 amount) public {
        vm.startPrank(address(1));
        mintAproveLong(address(1), amount, 0);
        pool.deposit(amount);
        vm.stopPrank();
        mlsp.cheatNewFuturePeriod();
        pool.startRollover();
    }

    function finishRoll(uint256 blockDuration) public {
        vm.roll(blockDuration);
        vm.startPrank(address(1));
        mintAproveLong(address(1), 10000, 1);
        mlsp.getNewestLsp().longToken().approve(address(pool), 10000);  
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
        mlsp.getNewestLsp().longToken().transfer(address(pool), 200);
        assertEq(pool.share().balanceOf(address(this)), 1000);

        pool.redeem(1000);
        assertEq(mlsp.getNewestLsp().longToken().balanceOf(address(this)), 1999);
    }

    function testRolloverDeposit() public {
        startRoll(10000);

        vm.roll(10000);
        mintAproveLong(address(this), 10000, 1);
        pool.rollDeposit(1000); 
        assertEq(mlsp.getNewestLsp().longToken().balanceOf(address(this)), 1100);
        assertEq(mlsp.getNewestLsp().longToken().balanceOf(address(this)), 9000);
    }

    function testRolloverWithdraw() public {
        startRoll(10000);

        vm.roll(10000);
        mintAproveLong(address(this), 10000, 1);
        pool.rollWithdraw(1100);
        assertEq(mlsp.getNewestLsp().longToken().balanceOf(address(this)), 1100);
        assertEq(mlsp.getNewestLsp().longToken().balanceOf(address(this)), 9000);
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
        assertEq(mlsp.getNewestLsp().longToken().balanceOf(address(this)), 9090);

        // assertEq(mlsp.getFutureToken(1, true).balanceOf(address(this)), 9090);
        // pool.redeem(1000);
        // assertEq()
        // assertEq(pool.)
    }
}

