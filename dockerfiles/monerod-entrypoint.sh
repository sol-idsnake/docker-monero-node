#!/bin/sh
set -e

HOSTNAME_PATH=/var/lib/tor/monerod-rpc/hostname

# Wait for Tor hidden service hostname to exist so we can log it for the user.
for i in $(seq 1 60); do
  if [ -f "${HOSTNAME_PATH}" ]; then
    if ONION=$(cat "${HOSTNAME_PATH}" 2>/dev/null); then
      echo "=========================================="
      echo "Monero restricted RPC Onion address: ${ONION}"
      echo "=========================================="
    else
      echo "Found ${HOSTNAME_PATH} but could not read it (permission denied?)"
    fi
    break
  fi
  echo "[${i}] Waiting for ${HOSTNAME_PATH}"
  sleep 1
done

DAEMON_USER=${DAEMON_USER:-monero}

# If running as root, drop privileges to the daemon user after logging.
if [ "$(id -u)" -eq 0 ] && [ "${DAEMON_USER}" != "root" ]; then
  if command -v runuser >/dev/null 2>&1; then
    exec runuser -u "${DAEMON_USER}" -- monerod "$@"
  elif command -v su >/dev/null 2>&1; then
    exec su -s /bin/sh -c "exec monerod \"$@\"" "${DAEMON_USER}"
  fi
fi

exec monerod "$@"
