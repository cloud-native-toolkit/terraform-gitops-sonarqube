#!/usr/bin/env bash

SCRIPT_DIR=$(cd $(dirname "$0"); pwd -P)
MODULE_DIR=$(cd "${SCRIPT_DIR}/.."; pwd -P)

DEST_DIR="$1"
SERVICE_URL="$2"

mkdir -p "${DEST_DIR}"

if [[ -z "${TMP_DIR}" ]]; then
  TMP_DIR="./.tmp/sonarqube"
fi
mkdir -p "${TMP_DIR}"

cp -R "${MODULE_DIR}/chart/sonarqube/"* "${DEST_DIR}"

if [[ -n "${VALUES_CONTENT}" ]]; then
  echo "${VALUES_CONTENT}" > "${DEST_DIR}/values.yaml"
fi

if [[ -n "${KUBESEAL_CERT}" ]]; then
  TEMPLATE_DIR="${DEST_DIR}/templates"
  mkdir -p "${TEMPLATE_DIR}"

  KUBESEAL_CERT_FILE="${TMP_DIR}/kubeseal.cert"
  echo "${KUBESEAL_CERT}" > "${KUBESEAL_CERT_FILE}"

  SECRET_FILE="${TMP_DIR}/sonarqube-access.yaml"
  cat > "${SECRET_FILE}" << EOL
apiVersion: v1
kind: Secret
metadata:
  name: sonarqube-access
  labels:
    app.kubernetes.io/part-of: sonarqube
    app: sonarqube
    app.kubernetes.op/name: sonarqube
    group: cloud-native-toolkit
  annotations:
    description: Secret to hold the username and password for sonarqube so that other components can access it
type: Opaque
stringData:
  SONARQUBE_URL: ${SERVICE_URL}
  SONARQUBE_PASSWORD: ${ADMIN_PASSWORD}
  SONARQUBE_USER: admin
EOL

  KUBESEAL=$(command -v kubeseal | command -v ./bin/kubeseal)
  if [[ -z "${KUBESEAL}" ]]; then
    BIN_DIR=$(cd ./bin; pwd -P)
    mkdir -p "${BIN_DIR}" && curl -Lo "${BIN_DIR}/kubeseal" https://github.com/bitnami-labs/sealed-secrets/releases/download/v0.16.0/kubeseal-linux-amd64
    chmod +x "${BIN_DIR}/kubeseal"
    KUBESEAL="${BIN_DIR}/kubeseal"
  fi

  echo "Kubeseal cert"
  cat "${KUBESEAL_CERT_FILE}"

  ${KUBESEAL} --cert "${KUBESEAL_CERT_FILE}" --format yaml < "${SECRET_FILE}" > "${TEMPLATE_DIR}/sonarqube-access.yaml"

  echo "Sealed secret"
  cat "${TEMPLATE_DIR}/sonarqube-access.yaml"
fi

find "${DEST_DIR}" -name "*"
