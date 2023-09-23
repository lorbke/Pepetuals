// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

import "forge-std/Test.sol";
import "../src/Api.sol";

// contract Currency is ERC20 {
//     constructor(string memory name, string memory symbol) ERC20(name, symbol) {}

//     function mint(address account, uint256 amount) public {
//         _mint(account, amount);
//     }

//     function burn(address account, uint256 amount) public {
//         _burn(account, amount);
//     }
// }

// contract ApiTest is Test {
//     Api public api;
//     Currency public currency;

//     function setUp() public {
//         currency = new Currency("currency", "curr");
//         api = new Api(currency);
//         api.registerStock("aapl");
//         api.registerStock("goog");
//     }

//     function testNames() public {
//         bytes32[] memory stockNames = api.getStockNames();
//         assertEq(stockNames[0], "aapl");
//         assertEq(stockNames[1], "goog");
//     }

//     function testBuy() public {
//         currency.mint(address(this), 1000);
//         currency.approve(address(api), 1000);
//         FutureIdentifier memory ident = FutureIdentifier("aapl", true, 0, 1);
//         api.buy(ident, 1000);

//         assertEq(api.getBalance(ident, address(this)), 1000);
//     }

//     function testPerpetualBuy() public {
//         currency.mint(address(this), 1000);
//         currency.approve(address(api), 1000);
//         FutureIdentifier memory ident = FutureIdentifier("aapl", true, type(uint32).max, 1);
//         api.buy(ident, 1000);

//         assertEq(api.getBalance(ident, address(this)), 1000);
//     }

//     function testRedeem() public {
//         currency.mint(address(this), 1000);
//         currency.approve(address(api), 1000);
//         FutureIdentifier memory ident = FutureIdentifier("aapl", true, 0, 1);
//         api.buy(ident, 1000);

//         assertEq(api.getBalance(ident, address(this)), 1000);
//         api.cheatFinishPeriod(ident, type(uint32).max / 2);
//         IERC20 token = api.getToken(ident);
//         token.approve(address(api), 1000);
//         api.redeem(ident, 1000);
//         assertEq(api.getBalance(ident, address(this)), 0);
//         // assertEq(currency.balanceOf(address(this)), 1000);
//     }

// }