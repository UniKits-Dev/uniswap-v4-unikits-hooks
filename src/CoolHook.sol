// // SPDX-License-Identifier: UNLICENSED
// pragma solidity >=0.8.20;

// import {BaseHook} from 'lib/v4-periphery/contracts/BaseHook.sol';
// import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
// import {IPoolManager} from '@uniswap/v4-core/contracts/interfaces/IPoolManager.sol';
// import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";

// contract CoolHook is BaseHook {

//     constructor(IPoolManager _poolManager) BaseHook(_poolManager) {}

//     // set hooks to true if it's enabled
//     function getHooksCalls() public pure override returns (Hooks.Calls memory) {
//         return Hooks.Calls({
//             beforeInitialize: false,
//             afterInitialize: false,
//             beforeModifyPosition: true,
//             afterModifyPosition: false,
//             beforeSwap: false,
//             afterSwap: false,
//             beforeDonate: false,
//             afterDonate: false
//         });
//     }

//     // Override the hook callbacks you want on your hook
//     function beforeModifyPosition(
//         address,
//         PoolKey calldata key,
//         IPoolManager.ModifyPositionParams calldata params
//     ) external override poolManagerOnly returns (bytes4) {
//         // hook logic
//         return BaseHook.beforeModifyPosition.selector;
//     }
// }

