#!/usr/bin/env bash
set -euo pipefail

EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-k8s-project}
EKS_REGION=${EKS_REGION:-us-east-1}

command -v eksctl >/dev/null 2>&1 || { echo "eksctl is required but not installed" >&2; exit 1; }

if eksctl get cluster --name "${EKS_CLUSTER_NAME}" --region "${EKS_REGION}" >/dev/null 2>&1; then
  eksctl delete cluster --name "${EKS_CLUSTER_NAME}" --region "${EKS_REGION}" --wait
  echo "Deleted EKS cluster ${EKS_CLUSTER_NAME} in ${EKS_REGION}"
else
  echo "EKS cluster ${EKS_CLUSTER_NAME} not found in ${EKS_REGION}. Nothing to do."
fi
