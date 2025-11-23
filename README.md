# Monero over Tor (with optional I2P)

This stack runs a Monero daemon behind Tor (and I2P) with only the restricted RPC exposed via onion.

## Components

- `tor`: Tor SOCKS proxy on `0.0.0.0:9050` and a hidden service mapping onion:18081 → monerod:18081.
- `i2p`: I2P proxy for outbound P2P; kept for extra reachability.
- `monerod`: downloads/verifies Monero `v0.18.4.4`, minimal runtime deps, exposes 18080/18081 for inter-container use only.
- `monerod-entrypoint.sh`: waits for the Tor onion hostname and logs it, then drops to the `monero` user before starting the daemon.
- `.env`: only `DATA_DIR` for host blockchain storage and `MONERO_VERSION`.

## Key configuration choices

- Restricted RPC only: limits surface area to wallet-safe methods; no host ports published.
- Core RPC loopback: monerod needs a core RPC listener to start the restricted RPC; bound to `127.0.0.1:18089` so it stays internal.
- Outbound privacy/reachability: Tor (`172.31.255.250:9050`) and I2P (`172.31.255.251:4447`) proxies hide your IP and let you talk to Tor/I2P peers; keep I2P for resilience.
- Chain data persisted: `${DATA_DIR:-./data}` is mounted at `/var/lib/monero` so the blockchain survives container rebuilds.
- Hygiene flags: DNS blocklist + ban list to avoid known-bad peers; non-interactive + confirm-external-bind to prevent prompts or accidental exposure.

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
