// SPDX-License-Identifier: MIT-License
pragma solidity ^0.8.0;

import {Test, console2} from "forge-std/Test.sol";
import {LongShortPairCreator} from "UMA/packages/core/contracts/financial-templates/long-short-pair/LongShortPair.sol";

contract LongShortPairCreatorTest is Test {
	LongShortPairCreator creator;

	function setUp() public {
		creator = new LongShortPairCreator();
	}

}