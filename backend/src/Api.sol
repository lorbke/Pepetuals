// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./IMultiLongShortPair.sol";
import "./RollingPool.sol";
import "./UniswapMock.sol";
import "./UniswapV3Wrapper.sol";

import {IUniswapV3Pool} from '@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol';
import 'uniswapv3-core/contracts/interfaces/callback/IUniswapV3MintCallback.sol';

interface ILongShortPair {
    function create(uint256 tokensToCreate) external returns (uint256 collateralUsed);
}

struct FutureIdentifier {
    bytes32 name;
    bool long;
    uint32 period; // MAX for perpetual
    uint8 leverage;
}

contract Api {
    using SafeERC20 for IERC20;

    mapping(bytes32=>mapping(uint8=>IMultiLongShortPair)) multiLongShortPairs;
    mapping(bytes32=>mapping(uint8=>RollingPool)) rollingPools;
    bytes32[] public futureNames;
    IERC20 collateral;
    UniswapV3Wrapper uniswapV3Wrapper;
    address finder;

    constructor(IERC20 _collateral, address _uniswapV3Wrapper, address _finder) {
        collateral = _collateral;
        uniswapV3Wrapper = UniswapV3Wrapper(_uniswapV3Wrapper);
        finder = _finder;
    }

    function getFutureNames() public view returns (bytes32[] memory) {
        return futureNames;
    }

    function registerFuture(bytes32 name, IMultiLongShortPair add) public {
        futureNames.push(name);
        // MultiLongShortPair lsp = new MultiLongShortPair(name, address(collateral), address(uniswapV3Wrapper), finder);
        multiLongShortPairs[name][1] = add;
        rollingPools[name][1] = new RollingPool(add);
    }

    function provideLiquidity(FutureIdentifier calldata ident, uint256 amount) public {
        IMultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        // collateral.approve(address(mlsp), amount);
        collateral.transferFrom(msg.sender, address(this), amount);
        uint32 period = ident.period; 
        // uint32 period = _isPerpetual(ident) ? mlsp.newestFutureId() : ident.period; 
        collateral.approve(address(mlsp.getLsp(period)), amount / 2);
        ILongShortPair(mlsp.getLsp(period)).create(amount / 2);

        // collateral.approve(mlsp.getPoolLongCollat(period), amount / 4);
        // collateral.approve(mlsp.getPoolShortCollat(period), amount / 4);
        IERC20(mlsp.getShortToken(period)).approve(mlsp.getPoolLongShort(period), amount / 4);        
        // mlsp.getLsp(period).shortToken().approve(mlsp.getPoolShortCollat(period), amount / 4);
        IERC20(mlsp.getLongToken(period)).approve(mlsp.getPoolLongShort(period), amount / 4);
        // mlsp.getLsp(period).longToken().approve(mlsp.getPoolLongCollat(period), amount / 4);

        UniswapMock(mlsp.getPoolLongShort(period)).provideLiquidity(amount / 4);
    }

    function buy(FutureIdentifier calldata ident, uint256 amount) public {
        IMultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        collateral.transferFrom(msg.sender, address(this), amount);
        uint32 period = ident.period; 
        if (_isPerpetual(ident)) {
            period = mlsp.getNewestPeriodId();
        }
        collateral.approve(address(mlsp.getLsp(period)), amount);
        ILongShortPair(mlsp.getLsp(period)).create(amount);
        // trade short to long or reverse
        IERC20(mlsp.getShortToken(period)).approve(mlsp.getPoolLongShort(period), amount);
        UniswapMock(mlsp.getPoolLongShort(period)).swap(amount, false);
        // uniswapV3Wrapper.sellToken(mlsp.getPoolLongShort(period), true, int256(amount));

        IERC20 longToken = IERC20(mlsp.getLongToken(period));
        if (!_isPerpetual(ident)) {
            longToken.transfer(msg.sender, amount * 2);
            return;
        }
        RollingPool rp = rollingPools[ident.name][ident.leverage];
        longToken.approve(address(rp), amount * 2);
        rp.deposit(amount * 2);
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
            IMultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
            token = IERC20(mlsp.getLongToken(ident.period));
        }
        return token;
    }

    function getBalance(FutureIdentifier calldata ident, address account) public view returns (uint256) {
        IERC20 token;
        if (_isPerpetual(ident)) {
            RollingPool rp = rollingPools[ident.name][ident.leverage];
            token = rp.share();
        } else {
            IMultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
            token = IERC20(mlsp.getLongToken(ident.period));
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
        // MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        // mlsp.cheatFinishPeriod(ident.period, priceChange);
    }

}

