.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SILENT:

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

help:
	echo "Usage: make [recipe]"
	echo "Recipes:"
	awk 'BEGIN {FS = ":.*?## "; sort_cmd = "sort"} \
		/^[a-zA-Z0-9_-]+:.*?## / { \
			printf "  \033[33m%-10s\033[0m %s\n", $$1, $$2 | sort_cmd; \
		} \
		END {close(sort_cmd)}' $(MAKEFILE_LIST)

nomos_bin := /usr/bin/nomos

$(nomos_bin):
	sudo apt-get install google-cloud-cli-nomos

status: $(nomos_bin) ## View GKE Fleet Config Sync status
	nomos status

version: ## View Git Commit
	echo "Code Versions:"
	echo "  Local: $(shell git rev-parse --short main)"
	echo "  Remote: $(shell git rev-parse --short origin/main)"

commit: ## Stage and Commit ALL changes
	version=$$(date +%Y.%m.%d-%H%M)
	git add --all
	git commit -m "$$version"
