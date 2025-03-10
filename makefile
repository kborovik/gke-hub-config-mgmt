.EXPORT_ALL_VARIABLES:
.ONESHELL:
.SILENT:

MAKEFLAGS += --no-builtin-rules --no-builtin-variables

settings:
	$(info Version: $(file < VERSION))

version:
	version=$$(date +%Y.%m.%d-%H%M)
	echo "$$version" >| VERSION
	git add --all

commit: version
	git commit -m "$$(cat VERSION)"
