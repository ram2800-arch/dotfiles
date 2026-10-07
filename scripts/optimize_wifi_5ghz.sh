#!/usr/bin/env bash
#
# optimize_wifi_5ghz.sh
# Diagnostic and optimization script to lock Wi-Fi connection to 5 GHz.

set -euo pipefail

# 1. Detect active wireless connection profile and interface
WIFI_DEV=$(nmcli -t -f DEVICE,TYPE device status | awk -F: '$2=="wifi"{print $1; exit}')

if [[ -z "${WIFI_DEV}" ]]; then
  echo "Error: No active Wi-Fi interface detected." >&2
  exit 1
fi

CONN_NAME=$(nmcli -t -f DEVICE,CONNECTION device status | awk -F: -v dev="$WIFI_DEV" '$1==dev{print $2; exit}')

if [[ -z "${CONN_NAME}" || "${CONN_NAME}" == "--" ]]; then
  echo "Error: Interface ${WIFI_DEV} is not connected to any network profile." >&2
  exit 1
fi

echo "=========================================="
echo " Wi-Fi Diagnostics: ${CONN_NAME} (${WIFI_DEV})"
echo "=========================================="

# 2. Inspect current association details
echo -e "\n[Current Connection Status]"
CURRENT_INFO=$(nmcli -t -f IN-USE,BSSID,SSID,CHAN,RATE,SIGNAL dev wifi | grep '^\*:' || true)

if [[ -n "${CURRENT_INFO}" ]]; then
  BSSID=$(echo "${CURRENT_INFO}" | cut -d: -f2-7)
  SSID=$(echo "${CURRENT_INFO}" | cut -d: -f8)
  CHAN=$(echo "${CURRENT_INFO}" | cut -d: -f9)
  RATE=$(echo "${CURRENT_INFO}" | cut -d: -f10)
  SIGNAL=$(echo "${CURRENT_INFO}" | cut -d: -f11)

  echo "  SSID:     ${SSID}"
  echo "  BSSID:    ${BSSID}"
  echo "  Channel:  ${CHAN}"
  echo "  Rate:     ${RATE}"
  echo "  Signal:   ${SIGNAL}%"

  if [[ "${CHAN}" -le 14 ]]; then
    echo "  Status:   Connected to 2.4 GHz (Suboptimal throughput)"
  else
    echo "  Status:   Connected to 5 GHz"
  fi
else
  echo "  Could not read active Wi-Fi link details."
fi

# 3. Check current NetworkManager band setting
CURRENT_BAND=$(nmcli -g 802-11-wireless.band connection show "${CONN_NAME}" 2>/dev/null || true)
echo -e "\n[Configured Band Policy]: ${CURRENT_BAND:-automatic/all}"

# 4. Enforce 5 GHz band lock if not already set
if [[ "${CURRENT_BAND}" != "a" ]]; then
  echo -e "\n>>> Locking connection '${CONN_NAME}' to 5 GHz (band 'a')..."
  nmcli connection modify "${CONN_NAME}" 802-11-wireless.band a

  echo ">>> Reconnecting interface to apply changes..."
  nmcli connection down "${CONN_NAME}" >/dev/null 2>&1 || true
  sleep 2
  nmcli connection up "${CONN_NAME}" >/dev/null 2>&1
else
  echo -e "\n>>> Profile '${CONN_NAME}' is already configured for 5 GHz ('band a')."
fi

# 5. Output verified final status
echo -e "\n=========================================="
echo " Final Wi-Fi Association"
echo "=========================================="
nmcli dev wifi | head -n 1
nmcli dev wifi | grep '^\*' || echo "Connecting..."
