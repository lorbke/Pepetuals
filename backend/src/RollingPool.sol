// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

import "./MultiLongShortPair.sol";

contract ShareToken is ERC20, Ownable {
    constructor(string memory name, string memory symbol) ERC20(name, symbol) Ownable() {}

    function mint(address account, uint256 amount) public onlyOwner {
        _mint(account, amount);
    }

    function burn(address account, uint256 amount) public onlyOwner {
        _burn(account, amount);
    }
}

contract RollingPool {
    using Math for uint256;

    MultiLongShortPair public lsp;
    ShareToken public share;
    IERC20 public oldFuture;
    IERC20 public newFuture;

    bool _rolling;
    uint256 _rollingStartBlock;

    constructor(MultiLongShortPair _lsp) {
        share = new ShareToken("Pool Shares", "POOL");
        lsp = _lsp;
        newFuture = lsp.activeFuture().longToken;
        _rolling = false;
        // twamm = new TWAMM();
    }

    function getFutureBalance(address account) public view returns (uint256) {
        return previewRedeem(share.balanceOf(account));
    }

    function previewDeposit(uint256 futures) public view virtual returns (uint256) {
        return _convertToFutures(futures, Math.Rounding.Down);
    }

    // pretend that _rolling didn't happen if its during _rolling?
    function deposit(uint256 futures) external {
        require(_rolling == false, "Cant deposit during _rolling");
        uint256 shares = previewDeposit(futures);
        newFuture.transferFrom(msg.sender, address(this), futures);
        share.mint(msg.sender, shares);
    }

    function previewRedeem(uint256 shares) public view virtual returns (uint256) {
        return _convertToFutures(shares, Math.Rounding.Down);
    }

    function redeem(uint256 shares) external {
        require(_rolling == false, "Cant redeem during rolling");
        uint256 futures = previewRedeem(shares);
        share.burn(msg.sender, shares);
        newFuture.transfer(msg.sender, futures);
    }

    function startRollover() external {
        IERC20 future = lsp.activeFuture().longToken;
        require(future != newFuture, "no new period");
        oldFuture = newFuture;
        newFuture = future;
        _rollingStartBlock = block.number;
        _rolling = true;
        // start trade
    }

    function rollDeposit(uint256 newFutures) external {
        require(_rolling == true, "not rolling");
        uint256 feeDuration = block.number - _rollingStartBlock + 1;
        uint256 feeTokens = newFutures.mulDiv(100000 + feeDuration, 100000, Math.Rounding.Down);
        newFuture.transferFrom(msg.sender, address(this), newFutures);
        oldFuture.transfer(msg.sender, feeTokens);
    }

    function rollWithdraw(uint256 oldFutures) external {
        require(_rolling == true, "not rolling");
        uint256 feeDuration = block.number - _rollingStartBlock;
        uint256 feeTokens = oldFutures.mulDiv(100000, feeDuration + 100000, Math.Rounding.Down);
        newFuture.transferFrom(msg.sender, address(this), feeTokens);
        oldFuture.transfer(msg.sender, oldFutures);
    }


    function totalAssets() internal view virtual returns (uint256) {
        return newFuture.balanceOf(address(this));
    }

    function _convertToShares(uint256 futures, Math.Rounding rounding) internal view virtual returns (uint256) {
        return futures.mulDiv(share.totalSupply(), totalAssets() + 1, rounding);
    }

    function _convertToFutures(uint256 shares, Math.Rounding rounding) internal view virtual returns (uint256) {
        return shares.mulDiv(totalAssets() + 1, share.totalSupply() + 1, rounding);
    }
}