// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract PairToken is ERC20, Ownable {
    constructor(
        string memory name,
        string memory symbol
    ) ERC20(name, symbol) Ownable() {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}

contract MultiLongShortPair {
    using SafeERC20 for IERC20;

    struct FuturePeriod {
        PairToken shortToken;
        PairToken longToken;
        bool finished;
        uint32 priceChange; // 0 = 0; 2 = type(uint32).max
    }

    mapping(uint32 => FuturePeriod) public futures;
    uint32 public newestFutureId;
    IERC20 currency;

    constructor(IERC20 _currency) {
        currency = _currency;
        newestFutureId = 0;
        newFuturePeriod(true);
    }

    function newFuturePeriod(bool firstPeriod) internal {
        if (!firstPeriod) {
            newestFutureId += 1;
        }
        futures[newestFutureId] = FuturePeriod(
            new PairToken("short Token", "SHORT"),
            new PairToken("long Token", "LONG"),
            false,
            0
        );
    }

    // function getBalance(address account, uint32 period, bool long) public view returns (uint256){
    //     return futures[period].longToken.balanceOf(account);
    // }

    function activeFuture() public view returns (FuturePeriod memory) {
        return futures[newestFutureId];
    }

    function getFutureToken(uint32 period, bool long) public view returns (IERC20) {
        return long ? futures[period].longToken : futures[period].shortToken;
    }

    function mint(address reciever, uint32 period, uint256 amount) public {
        if (period > newestFutureId) {
            period = newestFutureId;
        }
        currency.transferFrom(reciever, address(this), amount);
        futures[period].shortToken.mint(reciever, amount);
        futures[period].longToken.mint(reciever, amount);
    }

    function burn(address reciever, uint256 amount) public {
        activeFuture().shortToken.burn(reciever, amount);
        activeFuture().longToken.burn(reciever, amount);
    }

    function redeem(address reciever, uint32 period, bool long, uint256 amount) public returns(uint256){
        FuturePeriod memory future = futures[period];
        require(future.finished, "Future hasn't finished");
        PairToken futureToken = long ? PairToken(future.longToken) : PairToken(future.shortToken);
        futureToken.burn(reciever, amount);
        // redeem logic
        return 100;
    }

    function cheatForceNewPeriod() public {
        newFuturePeriod(false);
    }

    function cheatFinishPeriod(uint32 period, uint32 priceChange) public {
        futures[period].finished = true;
        futures[period].priceChange = priceChange;
        // newFuturePeriod(false);
    }
}
