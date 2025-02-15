## Migratoor

Migratoor is a PoC for converting chains from individual DisputeGameFactory instances publishing Output Roots to
a combined DisputeGameFactory for an interop cluster publishing Super Roots. It enables this via a permissionless system
where anyone can supply a set of output roots from the source chains which have been accepted via the existing 
single-chain dispute games. Migratoor then uses these outputs to build an equivalent Super Root that can be used
as the anchor state for games in the combined DisputeGameFactory.

One key restriction, is that the referenced output roots from each chain in the dependency set must have the same 
timestamp. Where chains in a cluster have different block times, this may result in some blocks being unusable for
migration because not all chains have a block with that exact timestamp. Since it is permissionless to publish outputs,
a later block can easily be chosen at a timestamp where all chains in the cluster publish a block.

For chains that are upgrading to a single-chain cluster (ie not joining the shared interop set), any block can be used.

## Out of Scope

One element here that is out of scope is a method on `AnchorStateRegistry` that allows the `Migratoor` to actually
set the new anchor state. It would have to restrict calls to the recognised `Migratoor` contract and ensure that the
anchor state can only progress forwards (ie only process updates where the timestamp is greater). This is essentially
the same logic already used when games resolve.


## Usage

### Build

```shell
$ forge build
```

### Test

```shell
$ forge test
```

### Format

```shell
$ forge fmt
```

### Gas Snapshots

```shell
$ forge snapshot
```

### Anvil

```shell
$ anvil
```

### Deploy

```shell
$ forge script script/Migratoor.s.sol:MigratoorScript --rpc-url <your_rpc_url> --private-key <your_private_key>
```

### Cast

```shell
$ cast <subcommand>
```

### Help

```shell
$ forge --help
$ anvil --help
$ cast --help
```
