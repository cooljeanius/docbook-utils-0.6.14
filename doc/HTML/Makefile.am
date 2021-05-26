htmldir	  = $(docdir)/html/docbook-utils-@VERSION@
html_DATA = api.html \
	backend-spec.html \
	docbook2man.html \
	docbook2texi.html \
	fdl.html \
	frontend-spec.html \
	helpers.html \
	index.html \
	introduction.html \
	intro-jw.html \
	intro-sgmldiff.html \
	jw.html \
	sgmldiff.html

CLEANFILES=$(html_DATA)

$(html_DATA): $(top_srcdir)/doc/docbook-utils.sgml \
		$(top_srcdir)/docbook-utils.dsl ../version \
		$(top_srcdir)/doc/refentry/jw.sgml \
		$(top_srcdir)/doc/refentry/backend-spec.sgml \
		$(top_srcdir)/doc/refentry/docbook2man-spec.pl.sgml \
		$(top_srcdir)/doc/refentry/docbook2texi-spec.pl.sgml \
		$(top_srcdir)/doc/refentry/frontend-spec.sgml \
		$(top_srcdir)/doc/refentry/sgmldiff.sgml
	SGML_CATALOG_FILES=/etc/sgml/catalog \
	SGML_SEARCH_PATH=$(top_srcdir):$(top_srcdir)/doc:.. \
		jade -t sgml -i html -d $(top_srcdir)/docbook-utils.dsl\#html \
			-V '%use-id-as-filename%' $<

