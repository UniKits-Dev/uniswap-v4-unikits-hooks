# UniKits -  Uniswap v4 hooks and tools

UniKits are a series of hooks and tools to enhance the functionality of UniSwap v4 Hooks. It's aimed to empower Uniswap-v4 Hooks with the following features:

* *Auth to Swap*
* *Swap to Share*
* Swap to Collect (in Future)
* Swap to Governance (in Future)
* etc..

### Auth to Swap

*Auth to Swap* module allows the uniswap-v4 pools authenticate the users identity before the swap. It means the user have to own a specificly identity before you can swap on a specific pool.

It can be used to create a fan based trading pool, or add the incentive to a specific group of people.

Following identity provider is planed to be supported:

* Lens Profile: [LensAuthHook.sol](./src/LensAuthHook.sol)
* ENS (WIP): [ENSAuthHook.sol](./src/ENSAuthHook.sol) (WIP)
* Worldcoin ID (WIP)
* etc..

## Swap to Share

*Swap to Share* enables the posibility for the pool to interact with on-chain social platforms.

* [LensPostHook.sol](./src/LensPostHook.sol)
* etc..

## Usage

* Replace LensHub address in deploy script

* Follow the local development guide to deploy

* Run it with tester

We believe On-Chain Composibility would be the core features for fully on-chain app. In this case, we choose to build based on Lens Protocol and Uniswap Protocol.

### Local Development (Anvil)

*requires [foundry](https://book.getfoundry.sh)*

```
forge install
forge test
```

Because v4 exceeds the bytecode limit of Ethereum and it's *business licensed*, we can only deploy & test hooks on [anvil](https://book.getfoundry.sh/anvil/) or other local testnet.

```bash
# start anvil, with a larger code limit
anvil --code-size-limit 30000

# Replace lensHub address in the deploy scripts first

# in a new terminal
# deploy Lens Auth Hook
forge script script/DeployLensAuthHook.s.sol \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --code-size-limit 30000 \
    --broadcast
    -vvvvv

# deploy Lens Post Hook
forge script script/DeployLensPostHook.s.sol \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --code-size-limit 30000 \
    --broadcast
    -vvvvv

```

## Arbitrum Local testnet deployment

A local arbitrum testnet has been launched and used to deploy the smart contracts.
---

Additional resources:

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)

## Thanks to

* [v4-template](https://github.com/saucepoint/v4-template)
* [uniswap-v4-custom-pool](uniswap-v4-custom-pool)
