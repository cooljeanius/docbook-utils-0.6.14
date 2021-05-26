man1dir	  = $(mandir)/man1
man1_MANS = jw.1 docbook2man-spec.pl.1 docbook2texi-spec.pl.1 sgmldiff.1

man7dir	  = $(mandir)/man7
man7_MANS = backend-spec.7 frontend-spec.7

EXTRA_DIST=$(man1_MANS) $(man7_MANS)

CLEANFILES=$(man1_MANS) $(man7_MANS) manpage.*

$(man1_MANS) $(man7_MANS): $(top_srcdir)/doc/docbook-utils.sgml \
		$(top_srcdir)/helpers/docbook2man-spec.pl
	SGML_CATALOG_FILES=/etc/sgml/catalog \
	SGML_SEARCH_PATH=$(top_srcdir)/doc:.. \
		nsgmls $< | \
		sgmlspl $(top_srcdir)/helpers/docbook2man-spec.pl
