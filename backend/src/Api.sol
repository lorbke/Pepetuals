// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

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
    address uniswapV3Wrapper;
    address finder;

    constructor(IERC20 _collateral, address _uniswapV3Wrapper, address _finder) {
        collateral = _collateral;
        uniswapV3Wrapper = _uniswapV3Wrapper;
        finder = _finder;
    }

    function getStockNames() public view returns (bytes32[] memory) {
        return stockNames;
    }

    function registerStock(bytes32 name) public {
        stockNames.push(name);
        MultiLongShortPair lsp = new MultiLongShortPair(name, address(collateral), uniswapV3Wrapper, finder);
        multiLongShortPairs[name][1] = lsp;
        rollingPools[name][1] = new RollingPool(lsp);
    }

    function buy(FutureIdentifier calldata ident, uint256 amount) public {
        MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
        collateral.transferFrom(msg.sender, address(this), amount);
        uint32 period = _isPerpetual(ident) ? mlsp.newestFutureId() : ident.period; 
        collateral.approve(address(mlsp.getLsp(period)), amount);
        mlsp.getLsp(period).create(amount);
        // trade short to long or reverse
        IERC20 longToken = IERC20(mlsp.getNewestLsp().longToken());

        if (!_isPerpetual(ident)) {
            longToken.transfer(msg.sender, amount);
            return;
        }
        RollingPool rp = rollingPools[ident.name][ident.leverage];
        longToken.approve(address(rp), amount);
        rp.deposit(amount);
        rp.share().transfer(msg.sender, amount);
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

