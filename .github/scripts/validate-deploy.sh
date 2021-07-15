#!/usr/bin/env bash

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
