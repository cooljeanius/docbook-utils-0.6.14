dnl#                                               -*- Autoconf -*-
dnl# Process this file with autoconf to produce a configure script.
AC_INIT([docbook-utils],[0.6.14],[ebisch@cybercable.tm.fr])
AC_CONFIG_SRCDIR([Makefile.am])
AC_CONFIG_AUX_DIR([build-aux])dnl

AC_DEFUN([AC_FIND_PROGRAM],
[
AC_MSG_CHECKING([for a decent directory to use for $3])
$3=""
for i in $2; do
  for j in $1; do
    if test -x "$i/$j"; then
      $3=$i
      AC_MSG_RESULT([$$3])
      break 2
    fi
  done
done
if test -z $$3; then
  AC_MSG_RESULT([not found])
fi
])dnl

AM_INIT_AUTOMAKE

docdir='$(prefix)/doc'
if test -n "${prefix}" && test -d "${prefix}/share/doc"; then
  docdir='$(prefix)/share/doc'
fi
AC_SUBST([docdir])dnl

dnl# Checks for programs.
AC_PROG_LN_S

jade_bindirs="/usr/bin /usr/local/bin"
if test -n "${prefix}" && test -d "${prefix}" && test "${prefix}" != "/usr/local"; then
  jade_bindirs="${jade_bindirs} ${prefix}/bin"
elif test -d /opt/local/bin; then
  jade_bindirs="${jade_bindirs} /opt/local/bin"
elif test -d /opt/sw/bin; then
  jade_bindirs="${jade_bindirs} /opt/sw/bin"
elif test -d /sw/bin; then
  jade_bindirs="${jade_bindirs} /sw/bin"
fi
AC_FIND_PROGRAM([nsgmls onsgmls],[${jade_bindirs}],[jade_bindir])
AC_SUBST([jade_bindir])dnl

perl_bindirs="/usr/bin /usr/local/bin"
if test -n "${prefix}" && test -d "${prefix}" && test "${prefix}" != "/usr/local"; then
  perl_bindirs="${perl_bindirs} ${prefix}/bin"
fi
AC_FIND_PROGRAM([perl],[${perl_bindirs}],[perl_bindir])
AC_SUBST([perl_bindir])dnl

# Output.
AC_CONFIG_FILES([Makefile docbook-utils.spec \
	bin/Makefile bin/jw bin/sgmldiff \
	backends/Makefile backends/man backends/texi \
	frontends/Makefile frontends/docbook \
	helpers/Makefile \
	doc/Makefile \
	doc/version \
	doc/refentry/Makefile \
	doc/man/Makefile \
	doc/HTML/Makefile])
AC_OUTPUT
