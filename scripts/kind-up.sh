#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME=${CLUSTER_NAME:-k8s-project}
KIND_CONFIG=${KIND_CONFIG:-kind-config.yaml}

if ! command -v kind >/dev/null 2>&1; then
  echo "kind is required but not installed" >&2
  exit 1
fi

if kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  echo "Cluster ${CLUSTER_NAME} already exists. Skipping creation."
  exit 0
fi

kind create cluster --name "${CLUSTER_NAME}" --config "${KIND_CONFIG}"

kubectl cluster-info --context "kind-${CLUSTER_NAME}" || true
