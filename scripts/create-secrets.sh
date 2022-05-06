#!/usr/bin/env bash

NAMESPACE="$1"
DEST_DIR="$2"

export PATH="${BIN_DIR}:${PATH}"

if ! command -v kubectl 1> /dev/null 2> /dev/null; then
  echo "kubectl cli not found" >&2
  exit 1
fi

mkdir -p "${DEST_DIR}"

#echo "***USER***: ${USERNAME}"
if [[ -z "${SERVICE_URL}" ]] || [[ -z "${ADMIN_PASSWORD}" ]] ; then
  echo "SERVICE_URL, ADMIN_PASSWORD must be provided as environment variables"
  exit 1
fi

kubectl create secret generic sonarqube-access \
  --from-literal="SONARQUBE_URL=${SERVICE_URL}" \
  --from-literal="SONARQUBE_PASSWORD=${ADMIN_PASSWORD}" \
  --from-literal="SONARQUBE_USER=admin" \
  -n "${NAMESPACE}" \
  --dry-run=client \
  --output=yaml > "${DEST_DIR}/sonarqube-access.yaml"
