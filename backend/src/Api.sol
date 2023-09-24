// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "uniswapv3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "./MultiLongShortPair.sol";
import "./RollingPool.sol";

struct FutureIdentifier {
    bytes32 name;
    bool long;
    uint32 period; // MAX for perpetual
    uint8 leverage;
}

contract Api {
    using SafeERC20 for IERC20;

    mapping(bytes32=>mapping(uint8=>MultiLongShortPair)) multiLongShortPairs;
    mapping(bytes32=>mapping(uint8=>RollingPool)) rollingPools;
    bytes32[] public stockNames;
    IERC20 collateral;
    UniswapV3Wrapper uniswapV3Wrapper;
    address finder;

    constructor(IERC20 _collateral, address _uniswapV3Wrapper, address _finder) {
        collateral = _collateral;
        uniswapV3Wrapper = UniswapV3Wrapper(_uniswapV3Wrapper);
        finder = _finder;
    }

    function getStockNames() public view returns (bytes32[] memory) {
        return stockNames;
    }

    function registerStock(bytes32 name) public {
        stockNames.push(name);
        MultiLongShortPair lsp = new MultiLongShortPair(name, address(collateral), address(uniswapV3Wrapper), finder);
        multiLongShortPairs[name][1] = lsp;
        rollingPools[name][1] = new RollingPool(lsp);
    }

    function provideLiquidity(FutureIdentifier calldata ident, uint256 amount) public {
        MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        collateral.transferFrom(msg.sender, address(this), amount);
        uint32 period = _isPerpetual(ident) ? mlsp.newestFutureId() : ident.period; 
        collateral.approve(address(mlsp.getLsp(period)), amount / 2);
        mlsp.getLsp(period).create(amount / 2);


        // INonfungiblePositionManager man = INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);
        // IUniswapV2Router02 router = UniswapV2Router02(0x7a250d5630B4cF539739dF2C5dAcb4c659F2488D);
        collateral.approve(address(man), amount);
        collateral.approve(address(man), amount);
        mlsp.getLsp(period).shortToken().approve(address(man), amount);        
        mlsp.getLsp(period).shortToken().approve(address(man), amount);
        mlsp.getLsp(period).longToken().approve(address(man), amount);
        mlsp.getLsp(period).longToken().approve(address(man), amount);

        // man.addLiquidity(
		// 	mlsp.getLsp(period).shortToken(),
		// 	mlsp.getLsp(period).longToken(),
		// 	10000,
		// 	10000,
		// 	0,
		// 	0,
		// 	msg.sender,
		// 	block.timestamp
		// );


        // INonfungiblePositionManager.MintParams memory params =
        //     INonfungiblePositionManager.MintParams({
        //         token0: mlsp.getLsp(period).shortToken(),
        //         token1: mlsp.getLsp(period).longToken(),
        //         fee: 3000,
        //         tickLower: 0,
        //         tickUpper: 887272,
        //         amount0Desired: amount,
        //         amount1Desired: amount,
        //         amount0Min: 0,
        //         amount1Min: 0,
        //         recipient: address(this),
        //         deadline: block.timestamp
        //     });

        // man.mint(params);
        // Note that the pool defined by DAI/USDC and fee tier 0.3% must already be created and initialized in order to mint
        // (tokenId, liquidity, amount0, amount1) = man.mint(params);

        // uniswapV3Wrapper.provideLiquidity(mlsp.getPoolShortCollat(period), uint128(amount / 4));
        // uniswapV3Wrapper.provideLiquidity(mlsp.getPoolLongShort(period), uint128(amount / 4));
        // uniswapV3Wrapper.provideLiquidity(mlsp.getPoolLongCollat(period), uint128(amount / 4));
    }

    function buy(FutureIdentifier calldata ident, uint256 amount) public {
        MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        collateral.transferFrom(msg.sender, address(this), amount);
        uint32 period = _isPerpetual(ident) ? mlsp.newestFutureId() : ident.period; 
        collateral.approve(address(mlsp.getLsp(period)), amount);
        mlsp.getLsp(period).create(amount);
        // trade short to long or reverse
        mlsp.getLsp(period).shortToken().approve(mlsp.getPoolLongShort(period), amount);
        // int256 tokenCount = int256(mlsp.getLsp(period).shortToken().balanceOf(address(this)));
        uniswapV3Wrapper.sellToken(mlsp.getPoolLongShort(period), true, int256(amount));
        // UniswapV3Wrapper(mlsp.getPool(period)).sellToken();
        IERC20 longToken = IERC20(mlsp.getNewestLsp().longToken());
        uint256 tokenCount = mlsp.getLsp(period).longToken().balanceOf(address(this));
        if (!_isPerpetual(ident)) {
            longToken.transfer(msg.sender, tokenCount);
            return;
        }
        RollingPool rp = rollingPools[ident.name][ident.leverage];
        longToken.approve(address(rp), tokenCount);
        rp.deposit(tokenCount);
        rp.share().transfer(msg.sender, rp.share().balanceOf(address(this)));
    }

    function sell(FutureIdentifier calldata ident, uint256 amount) public {
        
    }

    function redeem(FutureIdentifier calldata ident, uint256 amount) public {
        require(_isPerpetual(ident) == false);
        // MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        // IERC20 token = mlsp.getFutureToken(ident.period, ident.long);
        // token.transferFrom(msg.sender, address(this), amount);
        // token.approve(address(mlsp), amount);
        // mlsp.redeem(address(this), ident.period, ident.long, amount);
        // mlsp.
        // mlsp.futures[0];
    }

    function getToken(FutureIdentifier calldata ident) public view returns (IERC20) {
        IERC20 token;
        if (_isPerpetual(ident)) {
            RollingPool rp = rollingPools[ident.name][ident.leverage];
            token = rp.share();
        } else {
            MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
            token = mlsp.getLsp(ident.period).longToken();
        }
        return token;
    }

    function getBalance(FutureIdentifier calldata ident, address account) public view returns (uint256) {
        IERC20 token;
        if (_isPerpetual(ident)) {
            RollingPool rp = rollingPools[ident.name][ident.leverage];
            token = rp.share();
        } else {
            MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
            token = mlsp.getLsp(ident.period).longToken();
        }
        return token.balanceOf(account);
    }

    function _isPerpetual(FutureIdentifier calldata ident) internal pure returns (bool) {
        return ident.period == type(uint32).max;
    }

    function cheatNewPeriod() public {

    }

    function cheatFinishPeriod(FutureIdentifier calldata ident, uint32 priceChange) public {
        require(_isPerpetual(ident) == false);
        MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        // mlsp.cheatFinishPeriod(ident.period, priceChange);
    }

}

