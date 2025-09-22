# Kubernetes Kustomize Makefile
# Usage examples:
#   make apply                 # apply dev overlay (default)
#   make apply OVERLAY=prod    # apply prod overlay
#   make diff                  # show diff between live and overlay
#   make delete                # delete resources from the overlay
#   make build                 # render YAML to build.yaml
#   make dev                   # apply dev overlay
#   make prod                  # apply prod overlay
#   make context               # show current kubectl context
#   make kind-up               # create local kind cluster
#   make kind-down             # delete local kind cluster
#   make eks-up                # create AWS EKS cluster
#   make eks-down              # delete AWS EKS cluster
#   make apply-dev             # alias: apply dev overlay
#   make delete-dev            # alias: delete dev overlay
#   make apply-prod            # alias: apply prod overlay
#   make delete-prod           # alias: delete prod overlay

# Variables
OVERLAY ?= dev
OVERLAYS_DIR := overlays
KUSTOMIZE_PATH := $(OVERLAYS_DIR)/$(OVERLAY)
BUILD_FILE ?= build.yaml

# Namespace is optional; if your kustomization sets namespace, you can ignore this
NAMESPACE ?=
NS_FLAG := $(if $(strip $(NAMESPACE)),-n $(NAMESPACE),)

# Kind cluster settings
CLUSTER_NAME ?= k8s-project
KIND_CONFIG ?= kind-config.yaml

# EKS settings
EKS_CLUSTER_NAME ?= k8s-project
EKS_REGION ?= us-east-1
EKSCTL_CONFIG ?= eksctl-config.yaml

.DEFAULT_GOAL := help

.PHONY: help
help: ## Show this help
	@awk 'BEGIN {FS = ":.*##"}; /^[a-zA-Z0-9_.-]+:.*?##/ {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo "\nVariables:"
	@echo "  OVERLAY (default: dev)  -> overlays/<overlay>"
	@echo "  BUILD_FILE (default: build.yaml)"
	@echo "  NAMESPACE (optional, overrides kubectl -n)"
	@echo "  CLUSTER_NAME (default: k8s-project)"
	@echo "  KIND_CONFIG (default: kind-config.yaml)"
	@echo "  EKS_CLUSTER_NAME (default: k8s-project)"
	@echo "  EKS_REGION (default: us-east-1)"
	@echo "  EKSCTL_CONFIG (default: eksctl-config.yaml)"

.PHONY: check
check: ## Check for required tools
	@command -v kubectl >/dev/null 2>&1 || { echo "kubectl is required but not installed"; exit 1; }

.PHONY: apply
apply: check ## Apply the selected overlay (OVERLAY=dev|prod)
	kubectl apply -k $(KUSTOMIZE_PATH) $(NS_FLAG)

.PHONY: delete
delete: check ## Delete resources from the selected overlay (OVERLAY=dev|prod)
	kubectl delete -k $(KUSTOMIZE_PATH) $(NS_FLAG)

.PHONY: diff
diff: check ## Show a server-side diff for the selected overlay
	kubectl diff -k $(KUSTOMIZE_PATH) $(NS_FLAG) || true

.PHONY: build
build: check ## Render manifests to $(BUILD_FILE)
	kubectl kustomize $(KUSTOMIZE_PATH) > $(BUILD_FILE)
	@echo "Wrote $(BUILD_FILE)"

.PHONY: get
get: check ## Get common resources in namespace (set NAMESPACE=... or rely on kustomization)
	kubectl get all $(NS_FLAG)

.PHONY: context
context: check ## Show current kubectl context and namespace
	@kubectl config current-context
	@kubectl config view --minify --output 'jsonpath={..namespace}{"\n"}' | sed 's/^$/default/'

# Convenience shortcuts
.PHONY: dev prod apply-dev delete-dev apply-prod delete-prod

dev: ## Apply dev overlay
	$(MAKE) apply OVERLAY=dev NAMESPACE=$(NAMESPACE)

prod: ## Apply prod overlay
	$(MAKE) apply OVERLAY=prod NAMESPACE=$(NAMESPACE)

apply-dev: ## Alias for applying dev overlay
	$(MAKE) apply OVERLAY=dev NAMESPACE=$(NAMESPACE)

delete-dev: ## Alias for deleting dev overlay
	$(MAKE) delete OVERLAY=dev NAMESPACE=$(NAMESPACE)

apply-prod: ## Alias for applying prod overlay
	$(MAKE) apply OVERLAY=prod NAMESPACE=$(NAMESPACE)

delete-prod: ## Alias for deleting prod overlay
	$(MAKE) delete OVERLAY=prod NAMESPACE=$(NAMESPACE)

# Kind cluster lifecycle
.PHONY: kind-up kind-down

kind-up: ## Create local kind cluster
	CLUSTER_NAME=$(CLUSTER_NAME) KIND_CONFIG=$(KIND_CONFIG) bash scripts/kind-up.sh

kind-down: ## Delete local kind cluster
	CLUSTER_NAME=$(CLUSTER_NAME) bash scripts/kind-down.sh

# EKS cluster lifecycle
.PHONY: eks-up eks-down

eks-up: ## Create AWS EKS cluster (2-node) with eksctl
	EKS_CLUSTER_NAME=$(EKS_CLUSTER_NAME) EKS_REGION=$(EKS_REGION) EKSCTL_CONFIG=$(EKSCTL_CONFIG) bash scripts/eks-up.sh

eks-down: ## Delete AWS EKS cluster
	EKS_CLUSTER_NAME=$(EKS_CLUSTER_NAME) EKS_REGION=$(EKS_REGION) bash scripts/eks-down.sh
