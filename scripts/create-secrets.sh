#!/usr/bin/env bash

NAMESPACE="$1"
DEST_DIR="$2"

if [[ -n "${BIN_DIR}" ]]; then
  export PATH="${BIN_DIR}:${PATH}"
fi

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

kubectl create secret generic -n "${NAMESPACE}" sonarqube-access \
  --from-literal="SONARQUBE_URL=${SERVICE_URL}" \
  --from-literal="SONARQUBE_PASSWORD=${ADMIN_PASSWORD}" \
  --from-literal="SONARQUBE_USER=admin" \
  --dry-run=client \
  -o yaml | \
kubectl label --local=true -f - --dry-run=client -o yaml \
  group=cloud-native-toolkit \
  grouping=garage-cloud-native-toolkit > "${DEST_DIR}/sonarqube-access.yaml"
