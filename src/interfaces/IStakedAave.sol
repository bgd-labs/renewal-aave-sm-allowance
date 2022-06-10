// SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

interface IStakedAave {
    function claimRewards(address to, uint256 amount) external;
}
