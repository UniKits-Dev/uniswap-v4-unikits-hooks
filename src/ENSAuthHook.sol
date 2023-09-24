// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.20;

import {BaseHook} from 'lib/v4-periphery/contracts/BaseHook.sol';
import {Hooks} from "@uniswap/v4-core/contracts/libraries/Hooks.sol";
import {IPoolManager} from '@uniswap/v4-core/contracts/interfaces/IPoolManager.sol';
import {BalanceDelta} from "@uniswap/v4-core/contracts/types/BalanceDelta.sol";
import {PoolKey} from "@uniswap/v4-core/contracts/types/PoolKey.sol";

abstract contract ENS {
    function resolver(bytes32 node) public virtual view returns (Resolver);
}

abstract contract Resolver {
    function addr(bytes32 node) public virtual view returns (address);
}

/**
 * ENSAuthHook
 * Only allow user with a ENS profile to trade
 */
contract ENSAuthHook is BaseHook {
    
    ENS ens;
    address collectModule;
    address referenceModule;

    error NoDefaultENSProfileSet();
    event ENSAuthPassed(address user);
    event ENSAuthFailed(address user);

    constructor(IPoolManager _poolManager, address _ensResolverAddress) BaseHook(_poolManager) {
        ens = ENS(_ensResolverAddress);
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

    function resolve(bytes32 node) public view returns(address) {
        Resolver resolver = ens.resolver(node);
        return resolver.addr(node);
    }

    // *WIP*
    function isAuthPass(address user) internal view returns (bool) {
        // Todo:: fix on-chain resolve
        // if (resolve(user)) {
        //     return true;
        // }

        return false;
    }

    function beforeSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        address user = abi.decode(data, (address));
        if (!isAuthPass(user)) {
            emit ENSAuthFailed(user);
            revert NoDefaultENSProfileSet();
        }
        emit ENSAuthPassed(user);
        return BaseHook.beforeSwap.selector;
    }
    
    function beforeModifyPosition(address, PoolKey calldata, IPoolManager.ModifyPositionParams calldata, bytes calldata data)
        external
        override
        returns (bytes4)
    {
        address user = abi.decode(data, (address));
        if (!isAuthPass(user)) {
            emit ENSAuthFailed(user);
            revert NoDefaultENSProfileSet();
        }
        emit ENSAuthPassed(user);
        return BaseHook.beforeModifyPosition.selector;
    }
}
