// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface IMultiLongShortPair
{
	function newFuturePeriod() external;
	function cheatNewFuturePeriod() external;
	function getLsp(uint32 periodId) external view returns (address);
	function getPoolLongShort(uint32 periodId) external view returns (address);
	function getPoolLongCollat(uint32 periodId) external view returns (address);
	function getPoolShortCollat(uint32 periodId) external view returns (address);
	function getNewestLsp() external view returns (address);
	function getLongToken(uint32 periodId) external view returns (address);
	function getShortToken(uint32 periodId) external view returns (address);
	function getNewestLongToken() external view returns (address);
	function getNewestPeriodId() external view returns (uint32);
}