SUBDIRS = refentry man HTML

EXTRA_DIST = docbook-utils.sgml

install-data-local:
	cd $(DESTDIR)/$(mandir)/man1 && ( \
	ln -sf jw.1 docbook2dvi.1; \
	ln -sf jw.1 docbook2html.1; \
	ln -sf jw.1 docbook2man.1; \
	ln -sf jw.1 docbook2pdf.1; \
	ln -sf jw.1 docbook2ps.1; \
	ln -sf jw.1 docbook2rtf.1; \
	ln -sf jw.1 docbook2tex.1; \
	ln -sf jw.1 docbook2texi.1)
