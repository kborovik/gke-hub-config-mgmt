.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SILENT:

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

help:
	echo "Usage: make [recipe]"
	echo "Recipes:"
	awk 'BEGIN {FS = ":.*?## "; sort_cmd = "sort"} \
		/^[a-zA-Z0-9_-]+:.*?## / { \
			printf "  \033[33m%-15s\033[0m %s\n", $$1, $$2 | sort_cmd; \
		} \
		END {close(sort_cmd)}' $(MAKEFILE_LIST)

nomos_bin := /usr/bin/nomos

$(nomos_bin):
	sudo apt-get install google-cloud-cli-nomos

version: ## View Git Commit
	echo "Code Versions:"
	echo "  Local: $(shell git rev-parse --short main)"
	echo "  Remote: $(shell git rev-parse --short origin/main)"

commit: ## Stage and Commit ALL changes
	version=$$(date +%Y.%m.%d-%H%M)
	git add --all
	git commit -m "$$version"

fleet-status: $(nomos_bin) ## View GKE Fleet Config Sync status
	nomos status

KUBECONFIG ?= $(HOME)/.kube/config

gke-auth: ## Create GKE authentication
	gcloud container fleet memberships get-credentials gke-0
	gcloud container fleet memberships get-credentials gke-1

gke-clean: ## Remove GKE authentication
	rm -f $(KUBECONFIG)

helm_dir := helm/apache
gke_namespace ?= default
app_name ?= apache

helm-show: ## Show Kubernetes manifests
	helm template $(app_name) $(helm_dir) --namespace $(gke_namespace) | bat -l yaml

helm-save: ## Save Kubernetes manifests
	helm template $(app_name) $(helm_dir) --namespace $(gke_namespace) | tee namespaces/apache/apache.yaml

helm-test: ## Test HELM chart
	helm upgrade $(app_name) $(helm_dir) --install --namespace $(gke_namespace) --debug --dry-run

helm-install: ## Install HELM chart
	$(call header,Deploying HELM)
	helm upgrade $(app_name) $(helm_dir) --install --namespace $(gke_namespace) --wait --timeout=5m --atomic
