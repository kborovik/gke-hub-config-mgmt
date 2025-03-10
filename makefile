.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SILENT:

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

settings:
	$(info Version:          $(file < VERSION))
	$(info Git Commit Long:  $(shell git rev-parse HEAD))
	$(info Git Commit Short: $(shell git rev-parse --short HEAD))

status:
	nomos status

version:
	version=$$(date +%Y.%m.%d-%H%M)
	echo "$$version" >| VERSION
	git add --all

commit: version
	git commit -m "$$(cat VERSION)"
