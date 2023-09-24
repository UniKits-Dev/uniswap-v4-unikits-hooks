// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface IPoolManagerTester {
    error InvalidActionType();

    function ZERO_BYTES() external view returns (bytes memory);

    function lockAcquired(bytes memory rawData) external returns (bytes memory);

    function poolKey()
        external
        view
        returns (
            Currency currency0,
            Currency currency1,
            uint24 fee,
            int24 tickSpacing,
            address hooks
        );

    function poolManager() external view returns (address);

    function runMP(
        int24 tickLower,
        int24 tickUpper,
        int256 liquidityDelta
    ) external returns (bytes memory result);

    function runSwap(
        bool zeroForOne,
        int256 amountSpecified,
        uint160 sqrtPriceLimitX96
    ) external returns (bytes memory result);
}

type Currency is address;

struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    address hooks;
}
