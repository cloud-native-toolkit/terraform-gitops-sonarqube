#!/usr/bin/env bash

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

NAMESPACE="gitops-sonarqube"
NAME="sonarqube"
SERVER_NAME="default"

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/2-services/cluster/${SERVER_NAME}/base/${NAME}.yaml" ]]; then
  echo "ArgoCD config missing - argocd/2-services/cluster/${SERVER_NAME}/base/${NAME}.yaml"
  exit 1
fi

echo "Argocd config - argocd/2-services/cluster/${SERVER_NAME}/base/${NAME}.yaml"
cat "argocd/2-services/cluster/${SERVER_NAME}/base/${NAME}.yaml"

if [[ ! -f "payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml" ]]; then
  echo "Application values not found - payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml"
  exit 1
fi

echo "Payload - payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml"
cat "payload/2-services/namespace/${NAMESPACE}/${NAME}/values-${SERVER_NAME}.yaml"

if [[ ! -f "payload/2-services/namespace/${NAMESPACE}/${NAME}/templates/sonarqube-access.yaml" ]]; then
  echo "Sonarqube secret missing - payload/2-services/namespace/${NAMESPACE}/${NAME}/templates/sonarqube-access.yaml"
  exit 1
fi

echo "Sonarqube secret - payload/2-services/namespace/${NAMESPACE}/${NAME}/templates/sonarqube-access.yaml"
cat "payload/2-services/namespace/${NAMESPACE}/${NAME}/templates/sonarqube-access.yaml"

cd ..
rm -rf .testrepo

count=0
until kubectl get namespace "${NAMESPACE}" 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for namespace: ${NAMESPACE}"
  count=$((count + 1))
  sleep 15
done

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for namespace: ${NAMESPACE}"
  exit 1
else
  echo "Found namespace: ${NAMESPACE}. Sleeping for 30 seconds to wait for everything to settle down"
  sleep 30
fi


count=0
until kubectl get secret -n "${NAMESPACE}" sonarqube-access 1> /dev/null 2> /dev/null || [[ $count -eq 20 ]]; do
  echo "Waiting for secret in ${NAMESPACE}: sonarqube-access"
  count=$((count + 1))
  sleep 15
done

kubectl get all -n "${NAMESPACE}"
kubectl describe sealedsecret -n "${NAMESPACE}"

if [[ $count -eq 20 ]]; then
  echo "Timed out waiting for secret in ${NAMESPACE}: sonarqube-access"
  exit 1
fi

kubectl get secret -n "${NAMESPACE}" sonarqube-access || exit 1

oc extract secret/sonarqube-access -n "${NAMESPACE}" --to=-
