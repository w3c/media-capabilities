index.html: index.bs
#	./format.py $<
	curl https://api.csswg.org/bikeshed/ -f -F file=@$< >$@;
