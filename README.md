# Monero over Tor (with optional I2P)

This stack runs a Monero daemon behind Tor (and I2P) with only the restricted RPC exposed via onion.

## Components

- `tor`: Tor SOCKS proxy on `0.0.0.0:9050` and a hidden service mapping onion:18081 → monerod:18081.
- `i2p`: I2P proxy for outbound P2P; kept for extra reachability.
- `monerod`: downloads/verifies Monero `v0.18.4.4`, minimal runtime deps, exposes 18080/18081 for inter-container use only.
- `monerod-entrypoint.sh`: waits for the Tor onion hostname and logs it, then drops to the `monero` user before starting the daemon.
- `.env`: only `DATA_DIR` for host blockchain storage and `MONERO_VERSION`.

## Key configuration choices

- Restricted RPC only: bound to `0.0.0.0:18081` inside the network; no host ports published. Use the logged onion to reach it.
- Core (unrestricted) RPC is loopback-only on `127.0.0.1:18089` because monerod requires a core RPC listener for the restricted RPC to start; it is not exposed.
- Outbound privacy: P2P proxy flags for Tor (`172.31.255.250:9050`) and I2P (`172.31.255.251:4447`) to hide your IP and reach Tor/I2P peers.
- Data dir: host `${DATA_DIR:-./data}` mounted at `/var/lib/monero`.
- Safety flags: DNS blocklist enabled, external binds confirmed, non-interactive mode, ban list mounted at `/ban_list.txt`.
- Removed as bloat for this use case: public unrestricted RPC, ZMQ bindings/port, unused env vars.

## Running

```sh
docker compose up -d --build
```

Watch the `monerod` logs for the onion address:

```sh
docker compose logs -f monerod
```

## Wallet use

- Point `monero-wallet-cli` (or wallet RPC) at `http://<onion>:18081` via Tor.
- No RPC ports are published to the host; all access should go through the onion service.
