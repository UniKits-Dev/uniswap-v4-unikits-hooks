// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import "forge-std/Script.sol";
import { BaseScript } from "./Base.s.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IHooks} from "@uniswap/v4-core/contracts/interfaces/IHooks.sol";
import {PoolManager} from "@uniswap/v4-core/contracts/PoolManager.sol";
import {PoolManagerTester} from "../src/PoolManagerTester.sol";
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {MockERC20} from "@uniswap/v4-core/test/foundry-tests/utils/MockERC20.sol";
import {IERC20Minimal} from "@uniswap/v4-core/contracts/interfaces/external/IERC20Minimal.sol";
import {LensAuthHook} from "../src/LensAuthHook.sol";
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {HookDeployer} from "../test/utils/HookDeployer.sol";
import {IPoolManagerTester} from "../src/interfaces/IPoolManagerTester.sol";


contract RunLensPostHookScript is BaseScript {
    using CurrencyLibrary for Currency;

    IPoolManager public poolManager;
    
    bytes public constant ZERO_BYTES = new bytes(0);
    uint160 private constant SQRT_RATIO_1_1 = 79228162514264337593543950336;
    address constant CREATE2_DEPLOYER = address(0x4e59b44847b379578588920cA78FbF26c0B4956C);

    function run() public broadcaster {
        
        address testerAddress = address(0xE915164570b027C2A0FfadcB1B672192E35BF008);
        IPoolManagerTester tester = IPoolManagerTester(testerAddress);

        // modifyPosition
        tester.runMP(73781, 74959, 1 ether); // 1600 1800
        // Swap
        tester.runSwap(true, 100, SQRT_RATIO_1_1);
    }
}
