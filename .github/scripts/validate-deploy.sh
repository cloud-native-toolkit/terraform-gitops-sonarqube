#!/usr/bin/env bash

export KUBECONFIG=$(cat .kubeconfig)
NAMESPACE=$(cat .namespace)

GIT_REPO=$(cat git_repo)
GIT_TOKEN=$(cat git_token)

mkdir -p .testrepo

git clone https://${GIT_TOKEN}@${GIT_REPO} .testrepo

cd .testrepo || exit 1

find . -name "*"

if [[ ! -f "argocd/2-services/active/sonarqube.yaml" ]]; then
  echo "ArgoCD config missing"
  exit 1
else
  echo "ArgoCD config found"
fi

cat argocd/2-services/active/sonarqube.yaml

if [[ ! -f "payload/2-services/sonarqube/values.yaml" ]]; then
  echo "Application values not found"
  exit 1
else
  echo "Application values found"
fi

cat payload/2-services/sonarqube/values.yaml

if [[ -f "payload/2-services/sonarqube/templates/sonarqube-access.yaml" ]]; then
  echo "Found sealed secret file"
  cat "payload/2-services/sonarqube/templates/sonarqube-access.yaml"
fi

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
