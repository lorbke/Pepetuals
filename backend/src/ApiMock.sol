// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

struct FutureIdentifier {
    bytes32 name;
    bool long;
    uint32 period; // MAX for perpetual
    uint8 leverage;
}

contract Api {
    using SafeERC20 for IERC20;

    // mapping(bytes32=>mapping(uint8=>MultiLongShortPair)) multiLongShortPairs;
    // mapping(bytes32=>mapping(uint8=>RollingPool)) rollingPools;
    bytes32[] public stockNames;
    // IERC20 collateral;
    // address uniswapV3Wrapper;
    // address finder;

    constructor() {
        registerStock("oil");
        registerStock("pepe");
    }

    function getStockNames() public view returns (bytes32[] memory) {
        return stockNames;
    }

    function registerStock(bytes32 name) public {
        stockNames.push(name);
    }

    function buy(FutureIdentifier calldata ident, uint256 amount) public {

    }

    function sell(FutureIdentifier calldata ident, uint256 amount) public {
        
    }

    function redeem(FutureIdentifier calldata ident, uint256 amount) public {
        require(_isPerpetual(ident) == false);
    }

    // function getToken(FutureIdentifier calldata ident) public view returns (IERC20) {
    //     IERC20 token;
    //     if (_isPerpetual(ident)) {
    //         RollingPool rp = rollingPools[ident.name][ident.leverage];
    //         token = rp.share();
    //     } else {
    //         MultiLongShortPair mlsp = multiLongShortPairs[ident.name][ident.leverage];
    //         // token = mlsp.getFutureToken(ident.period, ident.long);
    //     }
    //     return token;
    // }

    function getBalance(FutureIdentifier calldata ident, address account) public view returns (uint256) {
        if (ident.name == 'pepe')
            return 10;
        if (ident.name == 'oil')
            return 5;
    }

    function _isPerpetual(FutureIdentifier calldata ident) internal pure returns (bool) {
        return ident.period == type(uint32).max;
    }

    function cheatNewPeriod() public {

    }

    function cheatFinishPeriod(FutureIdentifier calldata ident, uint32 priceChange) public {
        require(_isPerpetual(ident) == false);
        // mlsp.cheatFinishPeriod(ident.period, priceChange);
    }

}

