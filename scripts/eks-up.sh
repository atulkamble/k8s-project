#!/usr/bin/env bash
set -euo pipefail

EKS_CLUSTER_NAME=${EKS_CLUSTER_NAME:-k8s-project}
EKS_REGION=${EKS_REGION:-us-east-1}
EKSCTL_CONFIG=${EKSCTL_CONFIG:-eksctl-config.yaml}

command -v eksctl >/dev/null 2>&1 || { echo "eksctl is required but not installed" >&2; exit 1; }
command -v aws >/dev/null 2>&1 || { echo "aws CLI is required but not installed" >&2; exit 1; }

if eksctl get cluster --name "${EKS_CLUSTER_NAME}" --region "${EKS_REGION}" >/dev/null 2>&1; then
  echo "EKS cluster ${EKS_CLUSTER_NAME} already exists in ${EKS_REGION}. Skipping creation."
else
  eksctl create cluster -f "${EKSCTL_CONFIG}" --name "${EKS_CLUSTER_NAME}" --region "${EKS_REGION}"
fi

aws eks update-kubeconfig --name "${EKS_CLUSTER_NAME}" --region "${EKS_REGION}" >/dev/null

kubectl cluster-info || true
