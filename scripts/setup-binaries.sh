#!/usr/bin/env bash

if [[ -z "${BIN_DIR}" ]]; then
  BIN_DIR="./bin"
fi
mkdir -p "${BIN_DIR}"

# Install jq if not available
JQ=$(command -v jq || command -v "${BIN_DIR}/jq")

if [[ -z "${JQ}" ]]; then
  echo "jq missing. Installing"
  while [[ -f "${BIN_DIR}/jq.tmp" ]]; do
    sleep 10
  done
  touch "${BIN_DIR}/jq.tmp"
  curl -Lo "${BIN_DIR}/jq.tmp" https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  chmod +x "${BIN_DIR}/jq.tmp"
  mv "${BIN_DIR}/jq.tmp" "${BIN_DIR}/jq"
  JQ="${BIN_DIR}/jq"
fi

IGC=$(command -v igc || command -v "${BIN_DIR}/igc")

if [[ -z "${IGC}" ]]; then
  echo "igc missing. Installing"
  while [[ -f "${BIN_DIR}/igc.tmp" ]]; do
    sleep 10
  done
  touch "${BIN_DIR}/igc.tmp"

  TYPE=$(cat /etc/os-release | grep -E "^ID=" | sed "s/ID=//g")
  if [[ "${TYPE}" != "alpine" ]]; then
    TYPE="linux"
  fi

  RELEASE=$(curl -s "https://api.github.com/repos/cloud-native-toolkit/ibm-garage-cloud-cli/releases/latest" | ${JQ} -r '.tag_name')
  URL="https://github.com/cloud-native-toolkit/ibm-garage-cloud-cli/releases/download/${RELEASE}/igc-${TYPE}"
  echo "Downloading igc from url: ${URL}"
  curl -Lo "${BIN_DIR}/igc.tmp" "${URL}"
  chmod +x "${BIN_DIR}/igc.tmp"
  mv "${BIN_DIR}/igc.tmp" "${BIN_DIR}/igc"
  IGC="${BIN_DIR}/igc"
fi

echo "Installed binaries"
ls "${BIN_DIR}"
