# UniKits

UniKits are a series of tools to enhance UniSwap v4 Hooks. It's aimed to empower Uniswap-v4 Hooks with the following functions:

* *Auth to Swap*
* *Swap to Share*
* etc..

### Auth to Swap

*Auth to Swap* means the user have to own a specificly identity before you can swap on a specific pool.

Following identity provider can be supported:

* Lens Profile: [LensAuthHook.sol](./src/LensAuthHook.sol)
* ENS (WIP)
* Worldcoin ID (WIP)
* etc..

## Swap to Share

*Swap to Share* enables the posibility for the pool to interact with on-chain social platforms.

* [LensPostHook.sol](./src/LensPostHook.sol)
* etc..

## Usage

1. The example hook [Counter.sol](src/Counter.sol) demonstrates the `beforeSwap()` and `afterSwap()` hooks
2. The test template [Counter.t.sol](test/Counter.t.sol) preconfigures the v4 pool manager, test tokens, and test liquidity.

---

### Local Development (Anvil)

*requires [foundry](https://book.getfoundry.sh)*

```
forge install
forge test
```

Because v4 exceeds the bytecode limit of Ethereum and it's *business licensed*, we can only deploy & test hooks on [anvil](https://book.getfoundry.sh/anvil/).

```bash
# start anvil, with a larger code limit
anvil --code-size-limit 30000

# in a new terminal
forge script script/Counter.s.sol \
    --rpc-url http://localhost:8545 \
    --private-key 0xac0974bec39a17e36ba4a6b4d238ff944bacb478cbed5efcae784d7bf4f2ff80 \
    --code-size-limit 30000 \
    --broadcast
```

---

Additional resources:

[v4-periphery](https://github.com/uniswap/v4-periphery) contains advanced hook implementations that serve as a great reference

[v4-core](https://github.com/uniswap/v4-core)

## Thanks

* [v4-template](https://github.com/saucepoint/v4-template)
* [uniswap-v4-custom-pool](uniswap-v4-custom-pool)
