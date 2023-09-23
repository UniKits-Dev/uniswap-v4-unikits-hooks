// SPDX-License-Identifier: BUSL-1.1
pragma solidity ^0.8.20;
import {Currency, CurrencyLibrary} from "@uniswap/v4-core/contracts/types/Currency.sol";
import {IPoolManager} from "@uniswap/v4-core/contracts/interfaces/IPoolManager.sol";
import {IERC20Minimal} from "@uniswap/v4-core/contracts/interfaces/external/IERC20Minimal.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";


/// @title Test
/// @notice Base contract that provides a modifier for preventing delegatecall to methods in a child contract
contract PoolManagerTester {
    using CurrencyLibrary for Currency;

    IPoolManager public poolManager;
    PoolKey public poolKey;
    
    bytes public constant ZERO_BYTES = new bytes(0);
    uint160 public constant SQRT_RATIO_1_1 = 79228162514264337593543950336;
    
    error InvalidActionType();
    
    enum ActionType {
        actionModifyPosition,
        actionSwap
    }

    struct GenericCallbackData {
        address sender;
        PoolKey key;
        ActionType actionType;
        bytes actionData;
    }

    event DebugCheck(uint256 index);

    constructor(address poolManagerAddress, PoolKey memory key) {
        poolManager = IPoolManager(poolManagerAddress);
        poolKey = key;
    }

    function runMP(int24 tickLower, int24 tickUpper, int256 liquidityDelta) external returns (bytes memory result) {
        IPoolManager.ModifyPositionParams memory mpParams = IPoolManager.ModifyPositionParams({
            tickLower: tickLower,   
            tickUpper: tickUpper,
            liquidityDelta: liquidityDelta
        });
        return poolManager.lock(abi.encode(GenericCallbackData(msg.sender, poolKey, ActionType.actionModifyPosition, abi.encode(mpParams))));
    }
    
    function runSwap(bool zeroForOne, int256 amountSpecified, uint160 sqrtPriceLimitX96) external returns (bytes memory result) {
        IPoolManager.SwapParams memory swapParams = IPoolManager.SwapParams({
            zeroForOne: zeroForOne,
            amountSpecified: amountSpecified,
            sqrtPriceLimitX96: sqrtPriceLimitX96
        });
        return poolManager.lock(abi.encode(GenericCallbackData(msg.sender, poolKey, ActionType.actionSwap, abi.encode(swapParams))));
    }

    function lockAcquired(bytes calldata rawData) external returns (bytes memory) {
        require(msg.sender == address(poolManager));
        // perform pool actions
        // Will trigger before/after swap
        GenericCallbackData memory data = abi.decode(rawData, (GenericCallbackData));
        
        BalanceDelta delta;
        if (data.actionType == ActionType.actionModifyPosition) {
            delta = poolManager.modifyPosition(data.key, abi.decode(data.actionData, (IPoolManager.ModifyPositionParams)), ZERO_BYTES);
        } else if (data.actionType == ActionType.actionSwap) {
            delta = poolManager.swap(data.key, abi.decode(data.actionData, (IPoolManager.SwapParams)), ZERO_BYTES);
        } else {
            revert InvalidActionType();
        }

        // Take: transfer from this contract
        // Settle: transfer from sender account
        if (delta.amount0() > 0) {
            if (data.key.currency0.isNative()) {
                poolManager.settle{value: uint128(delta.amount0())}(data.key.currency0);
            } else {
                IERC20Minimal(Currency.unwrap(data.key.currency0)).transferFrom(
                    data.sender, address(poolManager), uint128(delta.amount0())
                );
                poolManager.settle(data.key.currency0);
            }
        }
        if (delta.amount1() > 0) {
            if (data.key.currency1.isNative()) {
                poolManager.settle{value: uint128(delta.amount1())}(data.key.currency1);
            } else {
                IERC20Minimal(Currency.unwrap(data.key.currency1)).transferFrom(
                    data.sender, address(poolManager), uint128(delta.amount1())
                );
                poolManager.settle(data.key.currency1);
            }
        }

        if (delta.amount0() < 0) {
            poolManager.take(data.key.currency0, data.sender, uint128(-delta.amount0()));
        }
        if (delta.amount1() < 0) {
            poolManager.take(data.key.currency1, data.sender, uint128(-delta.amount1()));
        }
        
        return abi.encode(delta);
    }
}
