// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseHook} from 'lib/v4-periphery/contracts/BaseHook.sol';
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from '@uniswap/v4-core/contracts/interfaces/IPoolManager.sol';
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {ILensHub} from './interfaces/ILensHub.sol'; 
import {DataTypes} from './interfaces/libraries/DataTypes.sol';
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";

/**
 * LensAuthHook
 * Only allow user with a lens profile to trade
 */
contract LensAuthHook is BaseHook {

    address lensHub;
    address collectModule;
    address referenceModule;

    error NoDefaultLensProfileSet();
    event LensAuthPassed(address user);
    event LensAuthFailed(address user);

    constructor(IPoolManager _poolManager, address _lensHubAddress) BaseHook(_poolManager) {
        lensHub = _lensHubAddress;
        collectModule = address(0);
        // referenceModule = address(0);
    }

    // set hooks to true if it's enabled
    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: true,
            afterModifyPosition: false,
            beforeSwap: true,
            afterSwap: false,
            beforeDonate: false,
            afterDonate: false
        });
    }

    // Returns default profile id of lens protocol. 
    // returns 0 if not mapping
    function getDefaultProfileId(address wallet) internal view returns (uint256) {
        return ILensHub(lensHub).defaultProfile(wallet);
    }

    function isAuthPass(address user) internal view returns (bool) {
        uint256 profileId = getDefaultProfileId(user);
        if (profileId == 0) {
            return false;
        }

        return true;
    }

    function beforeSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        address user = abi.decode(data, (address));
        if (!isAuthPass(user)) {
            emit LensAuthFailed(user);
            revert NoDefaultLensProfileSet();
        }
        emit LensAuthPassed(user);
        return BaseHook.beforeSwap.selector;
    }
    
    function beforeModifyPosition(address, PoolKey calldata, IPoolManager.ModifyPositionParams calldata, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        address user = abi.decode(data, (address));
        if (!isAuthPass(user)) {
            emit LensAuthFailed(user);
            revert NoDefaultLensProfileSet();
        }
        emit LensAuthPassed(user);
        return BaseHook.beforeModifyPosition.selector;
    }
 
    function setLensHub(address _lensHub) poolManagerOnly external {
        lensHub = _lensHub;
    }
}
