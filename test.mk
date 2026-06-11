TS0 = -mkdir -p $(dir $@); date >> $@; printf "$$(tail $@)\n" > $@; chgrp tmp $@
TS = @$(TS0)

allTests:=$(wildcard tests/*.pl)

all:  $(addprefix done/, $(notdir $(basename $(allTests))))
	@echo "*****\nall tests passed\n*****"

# Firefox is not allowed to access my full directory tree, so I copy the files to /tmp/DB/
done/%: tests/%.pl /tmp/DB/%.html /tmp/DB/DB.js
	@mkdir -p $(dir $@)
	perl $<
	@rm -rf /tmp/firefox_marionette_local*
	$(TS)

/tmp/DB/%.html: tests/%.html
	@mkdir -p $(dir $@)
	cat $< > $@

/tmp/DB/DB.js: DB.min.js
	@mkdir -p $(dir $@)
	cat $< > $@

clean:
	-rm -r done /tmp/DB

.PHONY: clean all
