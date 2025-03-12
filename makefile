.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SILENT:

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

default: help

nomos_bin := /usr/bin/nomos

$(nomos_bin):
	sudo apt-get install google-cloud-cli-nomos

git-log: ## View Git Commit
	echo "Code Versions:"
	echo "  Local: $(shell git rev-parse --short main)"
	echo "  Remote: $(shell git rev-parse --short origin/main)"

commit: ## Stage and Commit ALL changes
	git commit -m "$(shell date +%Y.%m.%d-%H%M)"

fleet-status: $(nomos_bin) ## View GKE Fleet Config Sync status
	echo "$(blue)GKE Clusters:$(reset)"
	gcloud container clusters list
	echo "$(blue)GKE Fleets:$(reset)"
	gcloud container fleet list
	echo "$(blue)GKE Fleets Membership:$(reset)"
	gcloud container fleet memberships list
	echo "$(blue)GKE Fleets Config Sync Status:$(reset)"
	nomos status

KUBECONFIG ?= $(HOME)/.kube/config

gke-auth: ## Create GKE authentication
	gcloud container fleet memberships get-credentials gke-0
	gcloud container fleet memberships get-credentials gke-1

gke-clean: ## Remove GKE authentication
	rm -f $(KUBECONFIG)

helm_chart := helm/apache
test_namespace ?= default
app_name ?= apache
app_namespace ?= apache

helm-show: ## Show Kubernetes manifests
	helm template $(app_name) $(helm_chart) --namespace $(app_namespace) | bat -l yaml

helm-save: ## Save Kubernetes manifests
	helm template $(app_name) $(helm_chart) --namespace $(app_namespace) | tee namespaces/apache/apache.yaml

helm-test: ## Test HELM chart
	helm upgrade $(app_name) $(helm_chart) --install --namespace $(test_namespace) --debug --dry-run

helm-install: ## Install HELM chart
	$(call header,Deploying HELM)
	helm upgrade $(app_name) $(helm_chart) --install --namespace $(test_namespace) --wait --timeout=5m --atomic

###############################################################################
# Colors and Headers
###############################################################################

TERM := xterm-256color

black := $$(tput setaf 0)
red := $$(tput setaf 1)
green := $$(tput setaf 2)
yellow := $$(tput setaf 3)
blue := $$(tput setaf 4)
magenta := $$(tput setaf 5)
cyan := $$(tput setaf 6)
white := $$(tput setaf 7)
reset := $$(tput sgr0)

define header
echo "$(blue)==> $(1) <==$(reset)"
endef

define var
echo "$(magenta)$(1)$(white): $(yellow)$(2)$(reset)"
endef

help:
	echo "$(blue)Usage: $(green)make [recipe]$(reset)"
	echo "$(blue)Recipes:$(reset)"
	awk 'BEGIN {FS = ":.*?## "; sort_cmd = "sort"} /^[a-zA-Z0-9_-]+:.*?## / \
	{ printf "  \033[33m%-15s\033[0m %s\n", $$1, $$2 | sort_cmd; } \
	END {close(sort_cmd)}' $(MAKEFILE_LIST)

prompt:
	printf "$(magenta)Continue $(white)? $(cyan)(yes/no)$(reset)"
	read -p ": " answer && [ "$$answer" = "yes" ] || exit 127
