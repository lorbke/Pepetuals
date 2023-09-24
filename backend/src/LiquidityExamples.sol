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

contract LiquidityExamples is IERC721Receiver {
    address public constant UNI = 0x1f9840a85d5aF5bf1D1762F925BDADdC4201F984;
    address public constant WETH = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address public constant POOL = 0x28cee28a7C4b4022AC92685C07d2f33Ab1A0e122;

    // 0.01% fee
    uint24 public constant poolFee = 100;

    INonfungiblePositionManager public nonfungiblePositionManager = 
        INonfungiblePositionManager(0xC36442b4a4522E871399CD717aBDD847Ab11FE88);

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

        ) = nonfungiblePositionManager.positions(_tokenId);
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

    function mintNewPosition()
        external
        returns (
            uint _tokenId,
            uint128 liquidity,
            uint amount0,
            uint amount1
        )
    {
        // For this example, we will provide equal amounts of liquidity in both assets.
        // Providing liquidity in both assets means liquidity will be earning fees and is considered in-range.
        uint amount0ToMint = 10000000;
        uint amount1ToMint = 10000000;

        // Approve the position manager
        TransferHelper.safeApprove(
            UNI,
            address(nonfungiblePositionManager),
            amount0ToMint
        );
        TransferHelper.safeApprove(
            WETH,
            address(nonfungiblePositionManager),
            amount1ToMint
        );

        INonfungiblePositionManager.MintParams
            memory params = INonfungiblePositionManager.MintParams({
                token0: UNI,
                token1: WETH,
                fee: poolFee,
                // By using TickMath.MIN_TICK and TickMath.MAX_TICK, 
                // we are providing liquidity across the whole range of the pool. 
                // Not recommended in production.
                tickLower: TickMath.MIN_TICK,
                tickUpper: TickMath.MAX_TICK,
                amount0Desired: amount0ToMint,
                amount1Desired: amount1ToMint,
                amount0Min: 0,
                amount1Min: 0,
                recipient: address(this),
                deadline: block.timestamp
            });

        // Note that the pool defined by DAI/USDC and fee tier 0.01% must 
        // already be created and initialized in order to mint
        (_tokenId, liquidity, amount0, amount1) = nonfungiblePositionManager
            .mint(params);

        // Create a deposit
        _createDeposit(msg.sender, _tokenId);

        // Remove allowance and refund in both assets.
        if (amount0 < amount0ToMint) {
            TransferHelper.safeApprove(
                UNI,
                address(nonfungiblePositionManager),
                0
            );
            uint refund0 = amount0ToMint - amount0;
            TransferHelper.safeTransfer(UNI, msg.sender, refund0);
        }

        if (amount1 < amount1ToMint) {
            TransferHelper.safeApprove(
                WETH,
                address(nonfungiblePositionManager),
                0
            );
            uint refund1 = amount1ToMint - amount1;
            TransferHelper.safeTransfer(WETH, msg.sender, refund1);
        }
    }
}