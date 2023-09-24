// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import "forge-std/Script.sol";
import "../src/Api.sol";
import "../src/UniswapV3Wrapper.sol";
import "../src/MultiLongShortPair.sol";
import "../src/IMultiLongShortPair.sol";

interface IUSDC is IERC20{
    function balanceOf(address account) external view returns (uint256);
    function mint(address to, uint256 amount) external;
    function configureMinter(address minter, uint256 minterAllowedAmount) external;
    function masterMinter() external view returns (address);
    function decimals() external view returns (uint32);
    // function approve(address acoount, uint256 amount) external;
}

contract MyScript is Script {
    IUSDC public collateral;

    address wrapper = 0x3C08514b6fEeFA7B8a881769c64a331789913640;
    address api = 0x8D9800f5035F915cB7f62e2fF0d505BB59E90b68;
    address factory = 0x1F98431c8aD98523631AE4a59f267346ea31F984;
    address FINDER = 0xE60dBa66B85E10E7Fd18a67a6859E241A243950e;
    address WETH9 = 0xB4FBF271143F4FBf7B91A5ded31805e42b2208d6;
    address nonfungiblePositionManager = 0xC36442b4a4522E871399CD717aBDD847Ab11FE88;

    IUSDC usdc = IUSDC(0x07865c6E87B9F70255377e024ace6630C1Eaa37F);

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        // vm.startBroadcast(deployerPrivateKey);

        // wrapper = new UniswapV3Wrapper(factory, WETH9, nonfungiblePositionManager);
        // collateral = usdc;
        // api = new Api(IERC20(collateral), address(wrapper), FINDER);
        // MultiLongShortPair mlsp = new MultiLongShortPair("aapl", address(collateral), address(wrapper), FINDER);
        // MultiLongShortPair mlspg = new MultiLongShortPair("goog", address(collateral), address(wrapper), FINDER);
        // api.registerFuture("aapl", IMultiLongShortPair(address(mlsp)));
        // api.registerFuture("goog", IMultiLongShortPair(address(mlspg)));

        // MultiLongShortPair mlsp = new MultiLongShortPair("pepe30495", address(collateral), address(wrapper), FINDER);
        // MultiLongShortPair mlspg = new MultiLongShortPair("oil2304", address(collateral), address(wrapper), FINDER);

        // api.registerFuture("pepe30495", IMultiLongShortPair(address(mlsp)));
        // api.registerFuture("oil2304", IMultiLongShortPair(address(mlspg)));
        // vm.stopBroadcast();

        vm.startBroadcast(deployerPrivateKey);
        MultiLongShortPair mlsp = new MultiLongShortPair("pepe", address(collateral), wrapper, FINDER);
        // MultiLongShortPair mlspg = new MultiLongShortPair("oil", address(collateral), address(wrapper), FINDER);

        Api(api).registerFuture("pepe", IMultiLongShortPair(address(mlsp)));
        // api.registerFuture("oil", IMultiLongShortPair(address(mlspg)));

        vm.stopBroadcast();
    }

    // function run2() external {
    //     uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
    //     vm.startBroadcast(deployerPrivateKey);

    //     MultiLongShortPair mlsp = new MultiLongShortPair("pepe", address(collateral), address(wrapper), FINDER);
    //     MultiLongShortPair mlspg = new MultiLongShortPair("oil", address(collateral), address(wrapper), FINDER);

    //     api.registerFuture("pepe", IMultiLongShortPair(address(mlsp)));
    //     api.registerFuture("oil", IMultiLongShortPair(address(mlspg)));

    //     vm.stopBroadcast();
    // }
}

//forge script script/Counter.sol:MyScript --rpc-url $RPC_URL --broadcast --verify -vvvv
