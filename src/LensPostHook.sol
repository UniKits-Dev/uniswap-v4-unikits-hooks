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
 * LensPostHook
 * This Hook is to report swap and position change to lens protocol.
 * It will automatically trigger a post when a posion change or swap occured.
 */
contract LensPostHook is BaseHook {

    address lensHub;
    address collectModule;
    address referenceModule;

    event NoDefaultLensProfileSet(address user);
    event ModifyPositionLensShared(address user, uint256 profileId, uint256 pubId);
    event SwapLensShared(address user, uint256 profileId, uint256 pubId);

    constructor(IPoolManager _poolManager, address _lensHubAddress) BaseHook(_poolManager) {
        lensHub = _lensHubAddress;
        collectModule = address(0);
        referenceModule = address(0);
    }

    // set hooks to true if it's enabled
    function getHooksCalls() public pure override returns (Hooks.Calls memory) {
        return Hooks.Calls({
            beforeInitialize: false,
            afterInitialize: false,
            beforeModifyPosition: false,
            afterModifyPosition: true,
            beforeSwap: false,
            afterSwap: true,
            beforeDonate: false,
            afterDonate: false
        });
    }

    // Returns default profile id of lens protocol. 
    // returns 0 if not mapping
    function getDefaultProfileId(address wallet) internal returns (uint256) {
        return ILensHub(lensHub).defaultProfile(wallet);
    }

    // function composeLensContentURI(
    //     string memory topic,
    //     IPoolManager.PoolKey calldata key,
    //     IPoolManager.ModifyPositionParams calldata params,
    //     BalanceDelta delta
    // ) internal pure returns (string memory) {
    //     // Todo: make a rule for this
    //     return topic;
    // }

    function afterModifyPosition(
        address,
        PoolKey calldata,
        IPoolManager.ModifyPositionParams calldata,
        BalanceDelta,
        bytes calldata data
    ) external override returns (bytes4) {
        address user = address(this);
        // address user = abi.decode(data, (address));
        // uint256 profileId = getDefaultProfileId(user);
        uint256 profileId = getDefaultProfileId(user);

        // if profile id is 0, it means no lens profile id mapped and will not trigger further actions.
        if (profileId == 0) {
            emit NoDefaultLensProfileSet(user);
            return LensPostHook.afterModifyPosition.selector;
        }
        string memory topic = 'mp';
        DataTypes.PostData memory postData = DataTypes.PostData({
            profileId: profileId,
            contentURI: topic, // composeLensContentURI(topic, key, params, delta),
            collectModule: collectModule,
            collectModuleInitData: '',
            referenceModule: referenceModule,
            referenceModuleInitData: ''
        });
        uint256 pubId = ILensHub(lensHub).post(postData);
        emit ModifyPositionLensShared(user, profileId, pubId);
        return LensPostHook.afterModifyPosition.selector;
    }

    function afterSwap(address, PoolKey calldata, IPoolManager.SwapParams calldata, BalanceDelta, bytes calldata data) external override returns (bytes4) {
        address user = address(this);  // By pass the auth for now
        // address user = abi.decode(data, (address));
        uint256 profileId = getDefaultProfileId(user);
        // if profile id is 0, it means no lens profile id mapped and will not trigger further actions.
        if (profileId == 0) {
            emit NoDefaultLensProfileSet(user);
            return LensPostHook.afterSwap.selector;
        }
        string memory topic = 'swap';
        DataTypes.PostData memory postData = DataTypes.PostData({
            profileId: profileId,
            contentURI: topic, // composeLensContentURI(topic, key, params, delta),
            collectModule: collectModule,
            collectModuleInitData: '',
            referenceModule: referenceModule,
            referenceModuleInitData: ''
        });
        uint256 pubId = ILensHub(lensHub).post(postData);
        emit SwapLensShared(user, profileId, pubId);
        return LensPostHook.afterSwap.selector;
    }
 
    function setLensHub(address _lensHub) poolManagerOnly external {
        lensHub = _lensHub;
    }

    // Lens Management
}
