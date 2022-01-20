.PHONY:	open
open:
	$(MAKE) slide.pdf
	evince slide.pdf &

-include include.mk

slide.pdf:	slide.saty
	eval `opam env` && satysfi "$<" | tee $(patsubst %.saty,%.out,$<) || cat $(patsubst %.saty,%.out,$<) | (tail -n 10 1>&2 && false)
	rm $(patsubst %.saty,%.out,$<)
	# mv $< $(patsubst %.pdf,%,$<)_bak.pdf
	# gs -sOutputFile=$< -sDEVICE=pdfwrite -sColorConversionStrategy=Gray -dProcessColorModel=/DeviceGray -dCompatibiltyLevel=1.4 -dNOPAUSE -dBATCH $(patsubst %.pdf,%,$<)_bak.pdf
	# rm $(patsubst %.pdf,%,$<)_bak.pdf

%.d:	%.saty
	@eval `opam env` && SATYROGRAPHOS_EXPERIMENTAL=1 satyrographos util deps-make "$<" --target "" --satysfi-version 0.0.5 2>/dev/null | tr ' :' '\n' | sed -e '/^$$/d' | while read LINE; do \
		cat "$$LINE" | sed -e 's/\(^\|[^\\]\)%.*$$/\1/' | sed -ne '/`/p' | sed -e 's/^.*`\([^`]*\)`.*$$/\1/' | sed -ne '/[a-zA-Z0-9]\+\.\(pdf\|jpg\)$$/p' | sed -e '/^http/d' | xargs -I{} echo '$(patsubst %.d,%.pdf,$@):	'`dirname "$$LINE"`'/{}' ; \
	done > "$@"


-include $(patsubst %.saty,%.d,$(wildcard *.saty))

.PHONY: clean
clean:
	rm -rf main.{d,satysfi-aux}

.PHONY: distclean
distclean:
	@$(MAKE) clean
	rm -rf main.pdf

