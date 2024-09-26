LOCAL_BIKESHED := $(shell command -v bikeshed 2> /dev/null)

index.html: index.bs
ifndef LOCAL_BIKESHED
	curl https://api.csswg.org/bikeshed/ -f -F file=@$< >$@;
else
	bikeshed spec
endif

ifdef LOCAL_BIKESHED
.PHONY: lint watch

lint: index.bs
	bikeshed --print=plain --dry-run --force spec --line-numbers $<

watch: index.bs
	@echo 'Browse to file://${PWD}/index.html'
	bikeshed --print=plain watch $<
endif  # LOCAL_BIKESHED



