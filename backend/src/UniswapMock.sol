// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// Import the ERC-20 interface
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/math/Math.sol";

contract UniswapMock {
    using Math for uint256;

    IERC20 public token1;
    IERC20 public token2;

    constructor(address _token1, address _token2) {
        token1 = IERC20(_token1);
        token2 = IERC20(_token2);
    }

    function provideLiquidity(uint256 amount) external {
        token1.transferFrom(msg.sender, address(this), amount);
        token2.transferFrom(msg.sender, address(this), amount);
    }

    function swap(uint256 amount, bool direction) external {
        if (direction) {
            token1.transferFrom(msg.sender, address(this), amount);
            token2.transfer(msg.sender, amount);
        } else {
            token2.transferFrom(msg.sender, address(this), amount);
            token1.transfer(msg.sender, amount);
        }
    }
}