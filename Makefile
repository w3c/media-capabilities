# make         Generate index.html from index.bs
# make lint    Check index.bs for warnings and errors
# make watch   Regenerate index.html after any change to index.bs

LOCAL_BIKESHED := $(shell command -v bikeshed 2> /dev/null)

index.html: index.bs
ifndef LOCAL_BIKESHED
	curl https://www.w3.org/publications/spec-generator/ -f -F type=bikeshed-spec -F file=@$< >$@;
else
	bikeshed spec
endif

ifdef LOCAL_BIKESHED
.PHONY: lint watch

lint: index.bs
	bikeshed --print=plain --dry-run --die-when=late --line-numbers spec $<

watch: index.bs
	@echo 'Browse to file://${PWD}/index.html'
	bikeshed --print=plain watch $<
endif  # LOCAL_BIKESHED
