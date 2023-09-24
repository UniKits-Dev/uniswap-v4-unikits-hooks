// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

interface ILensPostHook {
    error HookAddressNotValid(address hooks);
    error HookNotImplemented();
    error InvalidPool();
    error LockFailure();
    error NotPoolManager();
    error NotSelf();
    event ModifyPositionLensShared(
        address user,
        uint256 profileId,
        uint256 pubId
    );
    event NoDefaultLensProfileSet(address user);
    event SwapLensShared(address user, uint256 profileId, uint256 pubId);

    function afterDonate(
        address,
        PoolKey memory,
        uint256,
        uint256,
        bytes memory
    ) external returns (bytes4);

    function afterInitialize(
        address,
        PoolKey memory,
        uint160,
        int24,
        bytes memory
    ) external returns (bytes4);

    function afterModifyPosition(
        address,
        PoolKey memory,
        IPoolManager.ModifyPositionParams memory,
        BalanceDelta,
        bytes memory data
    ) external returns (bytes4);

    function afterSwap(
        address,
        PoolKey memory,
        IPoolManager.SwapParams memory,
        BalanceDelta,
        bytes memory data
    ) external returns (bytes4);

    function beforeDonate(
        address,
        PoolKey memory,
        uint256,
        uint256,
        bytes memory
    ) external returns (bytes4);

    function beforeInitialize(
        address,
        PoolKey memory,
        uint160,
        bytes memory
    ) external returns (bytes4);

    function beforeModifyPosition(
        address,
        PoolKey memory,
        IPoolManager.ModifyPositionParams memory,
        bytes memory
    ) external returns (bytes4);

    function beforeSwap(
        address,
        PoolKey memory,
        IPoolManager.SwapParams memory,
        bytes memory
    ) external returns (bytes4);

    function getHooksCalls() external pure returns (Hooks.Calls memory);

    function lockAcquired(bytes memory data) external returns (bytes memory);

    function poolManager() external view returns (address);

    function setDefaultProfile(uint256 profileId) external;

    function setLensHub(address _lensHub) external;
}

interface IPoolManager {
    struct ModifyPositionParams {
        int24 tickLower;
        int24 tickUpper;
        int256 liquidityDelta;
    }

    struct SwapParams {
        bool zeroForOne;
        int256 amountSpecified;
        uint160 sqrtPriceLimitX96;
    }
}

interface Hooks {
    struct Calls {
        bool beforeInitialize;
        bool afterInitialize;
        bool beforeModifyPosition;
        bool afterModifyPosition;
        bool beforeSwap;
        bool afterSwap;
        bool beforeDonate;
        bool afterDonate;
    }
}

type Currency is address;

struct PoolKey {
    Currency currency0;
    Currency currency1;
    uint24 fee;
    int24 tickSpacing;
    address hooks;
}

type BalanceDelta is int256;
