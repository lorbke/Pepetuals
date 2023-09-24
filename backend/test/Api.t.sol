// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";
import "../src/Api.sol";
import "../src/MultiLongShortPair.sol";
import "../src/IMultiLongShortPair.sol";

interface IUSDC is IERC20{
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
    // function approve(address acoount, uint256 amount) external;
}

contract ApiTest is Test {
    Api public api;
    IUSDC public collateral;
    UniswapV3Wrapper public wrapper;
    address factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address FINDER = 0xE60dBa66B85E10E7Fd18a67a6859E241A243950e;
    address WETH9 = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address nonfungiblePositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    IUSDC usdc = IUSDC(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);

    function allowMint() public {
        vm.prank(usdc.masterMinter());
        usdc.configureMinter(address(this), type(uint256).max);
    }

    function setUp() public {
        uint256 fork = vm.createFork(vm.envString("RPC_URL"));
		vm.selectFork(fork);
        collateral = usdc;

        wrapper = new UniswapV3Wrapper(factory, WETH9, nonfungiblePositionManager);
        api = new Api(IERC20(collateral), address(wrapper), FINDER);
        MultiLongShortPair mlsp = new MultiLongShortPair("aapl", address(collateral), address(wrapper), FINDER);
        MultiLongShortPair mlspg = new MultiLongShortPair("goog", address(collateral), address(wrapper), FINDER);

        api.registerFuture("aapl", IMultiLongShortPair(address(mlsp)));
        api.registerFuture("goog", IMultiLongShortPair(address(mlspg)));
        allowMint();
    }

    function testNames() public {
        bytes32[] memory stockNames = api.getFutureNames();
        assertEq(stockNames[0], "aapl");
        assertEq(stockNames[1], "goog");

    }

    function testBuy() public {
        FutureIdentifier memory long = FutureIdentifier("aapl", true, 1, 1);
        FutureIdentifier memory short = FutureIdentifier("aapl", false, 1, 1);

        address longToken = address(api.getToken(long));
        address shortToken = address(api.getToken(short));

        FutureIdentifier memory ident = FutureIdentifier("aapl", true, 1, 1);
        collateral.mint(address(this), 20000e6);
        collateral.approve(address(api), 20000e6);
        api.provideLiquidity(ident, 20000e6);

        ident = FutureIdentifier("aapl", true, type(uint32).max, 1);
        collateral.mint(address(this), 20000);
        collateral.approve(address(api), 20000);
        api.buy(ident, 20000);

        assertEq(api.getBalance(ident, address(this)), 40000);
        assertEq(collateral.balanceOf(address(this)), 0);
    }

    // function testPerpetualBuy() public {
    //     collateral.mint(address(this), 1000);
    //     collateral.approve(address(api), 1000);
    //     FutureIdentifier memory ident = FutureIdentifier("aapl", true, type(uint32).max, 1);
    //     api.buy(ident, 1000);

    //     assertEq(api.getBalance(ident, address(this)), 1000);
    // }

    // function testRedeem() public {
    //     collateral.mint(address(this), 1000);
    //     collateral.approve(address(api), 1000);
    //     FutureIdentifier memory ident = FutureIdentifier("aapl", true, 0, 1);
    //     api.buy(ident, 1000);

    //     assertEq(api.getBalance(ident, address(this)), 1000);
    //     api.cheatFinishPeriod(ident, type(uint32).max / 2);
    //     IERC20 token = api.getToken(ident);
    //     token.approve(address(api), 1000);
    //     api.redeem(ident, 1000);
    //     assertEq(api.getBalance(ident, address(this)), 0);
    //     // assertEq(collateral.balanceOf(address(this)), 1000);
    // }

}