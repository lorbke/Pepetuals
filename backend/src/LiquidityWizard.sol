// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity >=0.7.6;
pragma abicoder v2;

import "forge-std/Test.sol";

import "@uniswap/v3-core/contracts/interfaces/IUniswapV3Pool.sol";
import "@uniswap/v3-core/contracts/libraries/TickMath.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721Receiver.sol";
import "@uniswap/v3-periphery/contracts/libraries/TransferHelper.sol";
import "@uniswap/v3-periphery/contracts/interfaces/INonfungiblePositionManager.sol";
import "@uniswap/v3-periphery/contracts/base/LiquidityManagement.sol";

contract LiquidityWizard is IERC721Receiver {
    // 0.01% fee
    uint24 public constant poolFee = 100;

    INonfungiblePositionManager public immutable manager;

    constructor (address _manager) {
        manager = INonfungiblePositionManager(_manager);
    }


    /// @notice Represents the deposit of an NFT
    struct Deposit {
        address owner;
        uint128 liquidity;
        address token0;
        address token1;
    }

    /// @dev deposits[tokenId] => Deposit
    mapping(uint => Deposit) public deposits;

    // Store token id used in this example
    uint public tokenId;

    // Implementing `onERC721Received` so this contract can receive custody of erc721 tokens
    function onERC721Received(
        address operator,
        address,
        uint _tokenId,
        bytes calldata
    ) external override returns (bytes4) {
        _createDeposit(operator, _tokenId);
        return this.onERC721Received.selector;
    }

    function _createDeposit(address owner, uint _tokenId) internal {
        (
            ,
            ,
            address token0,
            address token1,
            ,
            ,
            ,
            uint128 liquidity,
            ,
            ,
            ,

        ) = manager.positions(_tokenId);
        // set the owner and data for position
        // operator is msg.sender
        deposits[_tokenId] = Deposit({
            owner: owner,
            liquidity: liquidity,
            token0: token0,
            token1: token1
        });

        console.log("Token id", _tokenId);
        console.log("Liquidity", liquidity);

        tokenId = _tokenId;
    }

    function getDeposit(uint _tokenId) external view returns (Deposit memory) {
        return deposits[_tokenId];
    }

    function mintNewPosition(address token0, address token1, uint256 amount0, uint256 amount1)
        external
        returns (
            uint _tokenId,
            uint128 liquidity,
            uint256 am0,
            uint256 am1
        )
    {

        TransferHelper.safeApprove(
            token0,
            address(this),
            amount0
        );

        TransferHelper.safeApprove(
            token1,
            address(this),
            amount1
        );

        TransferHelper.safeTransferFrom(
            token0,
            msg.sender,
            address(this),
            amount0
        );

        TransferHelper.safeTransferFrom(
            token1,
            msg.sender,
            address(this),
            amount1
        );

        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.

        // Approve the position manager
        TransferHelper.safeApprove(
            token0,
            address(manager),
            amount0
        );
        TransferHelper.safeApprove(
            token1,
            address(manager),
            amount1
        );

        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: token0,
                token1: token1,
                fee: poolFee,
                // By using TickMath.MIN_TICK and TickMath.MAX_TICK, 
                // we are providing liquidity across the whole range of the pool. 
                // Not recommended in production.
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                amount0Desired: amount0,
                amount1Desired: amount1,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        // Note that the pool defined by DAI/USDC and fee tier 0.01% must 
        // already be created and initialized in order to mint
        (_tokenId, liquidity, amount0, amount1) = manager
            .mint(params);

        // Create a deposit
        _createDeposit(msg.sender, _tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0) {
            TransferHelper.safeApprove(
                token0,
                address(manager),
                0
            );
            uint refund0 = amount0 - amount0;
            TransferHelper.safeTransfer(token0, msg.sender, refund0);
        }

        if (amount1 < amount1) {
            TransferHelper.safeApprove(
                token1,
                address(manager),
                0
            );
            uint refund1 = amount1 - amount1;
            TransferHelper.safeTransfer(token1, msg.sender, refund1);
        }
    }
}