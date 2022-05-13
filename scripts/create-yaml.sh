
#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

DEST_DIR="$1"
VALUES_FILE="$2"

mkdir -p "${DEST_DIR}"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp/sonarqube"
fi
mkdir -p "${TMP_DIR}"

cp -R "${MODULE_DIR}/chart/sonarqube/"* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi

if [[ -n "${VALUES_SERVER_CONTENT}" ]] && [[ -n "${VALUES_FILE}" ]]; then
  echo "${VALUES_SERVER_CONTENT}" > "${DEST_DIR}/${VALUES_FILE}"
fi
