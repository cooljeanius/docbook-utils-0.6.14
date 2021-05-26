=head1 NAME

docbook2texi-spec - convert DocBook Books to a Texinfo document

=head1 DESCRIPTION

This is a sgmlspl spec file that produces a Texinfo file
from DocBook markup.

=head1 LIMITATIONS

Trying docbook2info on non-DocBook or non-conformant SGML results in
undefined behavior. :-)

This program is a slow, dodgy Perl script.  

=head1 COPYRIGHT

Copyright (C) 1998-1999 Steve Cheng <steve@ggi-project.org>

This program is free software; you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation; either version 2, or (at your option) any later
version.

You should have received a copy of the GNU General Public License along with
this program; see the file COPYING.  If not, please write to the Free
Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

=cut

# $Id: docbook2texi-spec.pl,v 1.1 2000/07/21 20:22:30 rosalia Exp $

use SGMLS;			# Use the SGMLS package.
use SGMLS::Output;		# Use stack-based output.
use SGMLS::Refs;

########################################################################
# SGMLSPL script produced automatically by the script sgmlspl.pl
#
# Document Type: BOOK
# Edited by: me :)
########################################################################


$nocollapse_whitespace = 0;	# Current whitespace collapse counter.
$newline_last = 1;		# At beginning of line?

$skip_inline = 0;
$id_counter = 1;
$raw_cdata = 0;

$basename = shift || "db2texi";

sgml('start', sub {
	$Refs = new SGMLS::Refs("$basename.refs");
});
sgml('end', sub {
	$Refs->warn();
});


########################################################################
#
# Output helpers 
#
########################################################################

sub save_cdata
{
	$raw_cdata++;
	push_output('string');
}
		
# Copied from docbook2man.
# Texinfo's newline rules aren't so stringent, so
# perhaps we can do away with at least some of these cases for speed.

sub texi_sgml
{
	if(ref($_[1]) eq 'CODE') {
		return &sgml;
	}
	
	my $s = $_[1];

	$s =~ s/\\/\\\\/g;
	$s =~ s/'/\\'/g;

	# \n at the beginning means start at beginning of line
	if($s =~ s/^\n//) {
		$sub = 'sub { output "\n" unless $newline_last++; ';
		if($s eq '') { 
			sgml($_[0], eval('sub { output "\n" unless $newline_last++; }'));
		} elsif($s =~ /\n$/) {
			sgml($_[0], eval("sub { output \"\\n\" unless \$newline_last++; output '$s'; }"));
		} else {
			sgml($_[0], eval("sub { output \"\\n\" unless \$newline_last; output '$s'; \$newline_last = 0; }"));
		}
	} else {
		if($s =~ /\n$/) {
			sgml($_[0], eval("sub { output '$s'; \$newline_last = 1; }"));
		} else {
			sgml($_[0], eval("sub { output '$s'; \$newline_last = 0; }"));
		}
	}
}

sub texi_output
{
	$_ = shift;
	if(s/^\n//) {
		output "\n" unless $newline_last++;
	}
	return if $_ eq '';
	
	output $_;

	if(@_) {
		output @_;
		$newline_last = (pop(@_) =~ /\n$/);
	} else {
		$newline_last = ($_ =~ /\n$/)
	}
}

# Fold lines into one, quote some characters
sub fold_string
{
	$_ = shift;
	
	for($_[0]) {
		tr/\t/\n  /;
		s/\@/\@\@/g;
		s/\{/\@\{/g;
		s/\}/\@\}/g;
	}
	
	# Trim whitespace from beginning and end.
	s/^ +//;
	s/ +$//;

	return $_;
}

# Another version of sgml(), for 'inline' @-commands,
# and prevent nesting them.
sub _inline
{
	my ($gi, $tcmd) = @_;
	
	$tcmd =~ s/\\/\\\\/g;
	$tcmd =~ s/'/\\'/g;

	sgml($gi, eval("sub { output '${tcmd}\{' unless \$raw_cdata or \$skip_inline++ }"));
	
	$gi =~ s/^</<\//;
	sgml($gi, eval("sub { output '}' unless \$raw_cdata or --\$skip_inline }"));
}


sub generate_id {
	return "ID" . $id_counter++;
}
    



########################################################################
#
# Metadata
#
########################################################################

sub author_start {
	if($_[0]->within('BOOKINFO')) {
		save_cdata();
	}
}
sub author_end {
	if($_[0]->within('BOOKINFO')) {
		texi_output('@author{' . fold_string(pop_output()) . "\}\n");
		$raw_cdata--;
	}
}

sgml('<AUTHOR>', \&author_start);
sgml('</AUTHOR>', \&author_end);
sgml('<EDITOR>', \&author_start);
sgml('</EDITOR>', \&author_end);
sgml('<COLLAB>', \&author_start);
sgml('</COLLAB>', \&author_end);
sgml('<CORPAUTHOR>', \&author_start);
sgml('</CORPAUTHOR>', \&author_end);
sgml('<OTHERCREDIT>', \&author_start);
sgml('</OTHERCREDIT>', \&author_end);

sgml('</FIRSTNAME>', ' ');
sgml('</SURNAME>', ' ');
sgml('</HONORIFIC>', ' ');
sgml('</LINEAGE>', ' ');
sgml('</OTHERNAME>', ' ');
sgml('</AFFILIATION>', ' ');

# Ignore content.
sgml('<CONTRIB>', sub { push_output('nul') });
sgml('</CONTRIB>', sub { pop_output });
sgml('<AUTHORBLURB>', sub { push_output('nul') });
sgml('</AUTHORBLURB>', sub { pop_output });

sgml('<DOCINFO>', sub { push_output('nul'); });
sgml('</DOCINFO>', sub { pop_output(); });
sgml('<REFSECT1INFO>', sub { push_output('nul'); });
sgml('</REFSECT1INFO>', sub { pop_output(); });
sgml('<REFSECT2INFO>', sub { push_output('nul'); });
sgml('</REFSECT2INFO>', sub { pop_output(); });
sgml('<REFSECT3INFO>', sub { push_output('nul'); });
sgml('</REFSECT3INFO>', sub { pop_output(); });

sgml('<TITLEABBREV>', sub { push_output('nul') });
sgml('</TITLEABBREV>', sub { pop_output() });

texi_sgml('<LEGALNOTICE>', "\n\@page\n\@vskip 0pt plus 1fill\n");

sgml('<BOOKINFO>', sub {
	texi_output("\n\@titlepage\n");
	texi_output('@title{', $doc_title, "\}\n");
});
#texi_sgml('</BOOKINFO>', "\n\@end titlepage\n");
texi_sgml('</BOOKINFO>', sub {
	texi_output "\n\@end titlepage\n\n";
	texi_output "\@node Top\n\@top\n\n";

	# Generate top menu for BOOK.
	$_[0]->parent->ext->{'output_toc'} = 1;
		
	# This is so that elements below can find me.
	$_[0]->parent->ext->{'id'} = $_[0]->parent->attribute('ID')->value || generate_id();
});

sgml('<TITLE>', \&save_cdata);
sgml('</TITLE>', sub { 
	my $title = fold_string(pop_output());
	$raw_cdata--;
	
	if($_[0]->in('BOOKINFO')) {
		texi_output("\n\@subtitle{", $title, "\}\n");
	}
	elsif(exists $_[0]->parent->ext->{'title'}) {
		# By far the easiest case.  Just fold the string as
		# above, and then set the parent element's variable.
		$_[0]->parent->ext->{'title'} = $title;
	}
	elsif(exists $_[0]->parent->ext->{'nodesection'}) {
		# Start new node, since we now know its title.

		# This node.
		$me = $_[0]->parent;
		
		my $nodename = fold_string($me->attribute('XREFLABEL')->value) || $title;
		$nodename =~ s/,/ /;
		
		texi_output("\n\n\@node $nodename\n");

		# The heading such as @chapter $title.
		texi_output($me->ext->{'nodesection'}, " $title\n");

		# This is so that elements below can find me.
		my $id = $me->attribute('ID')->value || generate_id();
		$me->ext->{'id'} = $id;

		# Don't overwrite info from previous parse.
		if($Refs->get($id) eq '') {
			$Refs->put($id, $nodename);
		
			# Add myself to parent node's list of nodes.
			my $pid = $me->parent->ext->{'id'};
			$Refs->put($pid, $Refs->get($pid) . ",$id");
		}
	}
	else {
		if($_[0]->in('BOOK')) {
			$doc_title = $title;
		}
		output $title, "\n";
		$newline_last++;
	}
});

# Appendix
# Article









########################################################################
#
# Major sectioning elements
#
########################################################################

sgml('<BOOK>', "\\input texinfo\n\@settitle ");
texi_sgml('</BOOK>', "\n\n\@bye\n");

# Start a new section with new node.  
# Most of the handling is at </TITLE>.
sub start_node
{
	$_[0]->ext->{'nodesection'} = $_[1];

	# Flag that the first child node ...
	$_[0]->ext->{'output_toc'} = 1;
	
	# ... need to output a list of nodes.
	if($_[0]->parent->ext->{'output_toc'}) {
		$_[0]->parent->ext->{'output_toc'} = 0;
		
		my @nodes = split(/,/, $Refs->get($_[0]->parent->ext->{'id'}));
		shift @nodes;

		texi_output("\n\n\@menu\n");

		foreach(@nodes) {
			my ($nodename) = split(/,/, $Refs->get($_));
			output "* ", $nodename, "::\n";
		}

		texi_output("\n\n\@end menu\n");
	}
}

sgml('<PREFACE>', sub { start_node $_[0], '@chapter'; });
sgml('<CHAPTER>', sub { start_node $_[0], '@chapter'; });

sgml('<SECT1>', sub { start_node $_[0], '@section'; });
sgml('<SECT2>', sub { start_node $_[0], '@subsection'; });
sgml('<SECT3>', sub { start_node $_[0], '@subsubsection'; });
sgml('<SECT4>', sub { start_node $_[0], '@subsubsection'; });
sgml('<SECT5>', sub { start_node $_[0], '@subsubsection'; });


########################################################################
#
# Reference pages
#
########################################################################

sgml('<REFENTRY>', sub {
	# Determine what it is under ...
	# FIXME! Add more of these parents!
	if($_[0]->in('CHAPTER')) {
		start_node $_[0], '@section';
	} elsif($_[0]->in('SECT1')) {
		start_node $_[0], '@subsection';
	} else {
		# From Sect2 and after
		start_node $_[0], '@subsubsection';
	}
});

sgml('<REFENTRYTITLE>', sub { 
	if($_[0]->in('REFMETA')) { 
		save_cdata();
	}
});
sgml('</REFENTRYTITLE>', sub { 
	if($_[0]->in('REFMETA')) { 
		my $title = fold_string(pop_output());
		$raw_cdata--;

		# This node.
		my $me = $_[0]->parent->parent;
				
		my $nodename = fold_string($me->attribute('XREFLABEL')->value) || $title;
		$nodename =~ s/,/ /;
		
		texi_output("\n\n\@node $nodename\n");

		# The heading such as @chapter $title.
		texi_output($me->ext->{'nodesection'}, " $title\n");

		# This is so that elements below can find me.
		my $id = $me->attribute('ID')->value || generate_id();
		$me->ext->{'id'} = $id;

		# Don't overwrite info from previous parse.
		if($Refs->get($id) eq '') {
			$Refs->put($id, $nodename);
		
			# Add myself to parent node's list of nodes.
			my $pid = $me->parent->ext->{'id'};
			$Refs->put($pid, $Refs->get($pid) . ",$id");
		}
	}
});

sgml('<MANVOLNUM>', sub { 
	if($_[0]->in('REFMETA')) { push_output('nul') }
	else			 { texi_output '(' }
});
sgml('</MANVOLNUM>', sub { 
	if($_[0]->in('REFMETA')) { pop_output() }
	else			 { texi_output ')' }
});

sgml('<REFMISCINFO>', sub { push_output('nul') });
sgml('</REFMISCINFO>', sub { pop_output() });

sgml('<REFNAMEDIV>', sub { 
	$_[0]->ext->{'first_refname'} = 1;

	# FIXME! Add more of these parents!
	if($_[0]->parent->in('CHAPTER')) {
		texi_output "\n\n\@unnumberedsubsec Name\n";
	} else {
		texi_output "\n\n\@unnumberedsubsubsec Name\n";
	}
});

sgml('<REFNAME>', sub {
	if($_[0]->parent->ext->{'first_refname'}) {
		$_[0]->parent->ext->{'first_refname'} = 0;
		return;
	}
	output ", ";
});

sgml('<REFPURPOSE>', " --- ");

# RefDescriptor

sgml('<REFSYNOPSISDIV>', sub { 
	# FIXME! Add more of these parents!
	if($_[0]->parent->in('CHAPTER')) {
		texi_output "\n\@unnumberedsubsec Synopsis\n";
	} else {
		texi_output "\n\@unnumberedsubsubsec Synopsis\n";
	}
});

sgml('<REFSECT1>', sub {
	# FIXME! Add more of these parents!
	if($_[0]->parent->in('CHAPTER')) {
		texi_output "\n\n\@unnumberedsubsec ";
	} else {
		texi_output "\\nn\@unnumberedsubsubsec ";
	}
});

sgml('<REFSECT2>', sub { start_node $_[0], '@unnumberedsubsubsec' });
sgml('<REFSECT3>', sub { start_node $_[0], '@unnumberedsubsubsec' });





########################################################################
#
# Synopses
#
########################################################################

sgml('<FUNCSYNOPSIS>', sub { $skip_inline++ });
sgml('</FUNCSYNOPSIS>', sub { $skip_inline-- });
sgml('<CMDSYNOPSIS>', sub { $skip_inline++ });
sgml('</CMDSYNOPSIS>', sub { $skip_inline-- });

sgml('<FUNCPROTOTYPE>', "\n\n");

# Arguments to functions.  This is C convention.
texi_sgml('<PARAMDEF>', '(');
texi_sgml('</PARAMDEF>', ');');
texi_sgml('<VOID>', '(void);');

## ARG: should be bold, but not needed.
#







########################################################################
#
# 'Useful highlighting' 
#
########################################################################


_inline('<CITETITLE>', '@cite');
_inline('<EMAIL>', '@email');
_inline('<FIRSTTERM>', '@dfn');
_inline('<FILENAME>', '@file');

_inline('<ACCEL>', '@key');
_inline('<KEYCAP>', '@key');
_inline('<KEYCOMBO>', '@key');
_inline('<KEYSYM>', '@key');
_inline('<USERINPUT>', '@kbd');

_inline('<LITERAL>', '@samp');
_inline('<MARKUP>', '@samp');
_inline('<SGMLTAG>', '@samp');
_inline('<TOKEN>', '@samp');

_inline('<CLASSNAME>', '@code');
_inline('<ENVAR>', '@code');
_inline('<FUNCTION>', '@code');
_inline('<PARAMETER>', '@code'); # not always
_inline('<RETURNVALUE>', '@code');
_inline('<STRUCTFIELD>', '@code');
_inline('<STRUCTNAME>', '@code');
_inline('<SYMBOL>', '@code');
_inline('<TYPE>', '@code');

_inline('<ACRONYM>', '@sc');
_inline('<EMPHASIS>', '@emph');

# Only in certain contexts
#sgml('<REPLACEABLE>'

sgml('<OPTIONAL>', "[");
sgml('</OPTIONAL>', "]");

sgml('<COMMENT>', "[Comment: ");
sgml('</COMMENT>', "]");

# ACTION
# ALT

# AUTHOR
# AUTHORINITIALS

# ABBREV
# CITATION
# FOREIGNPHRASE
# PHRASE
# QUOTE
# WORDASWORD

# COMPUTEROUTPUT
# LITERAL
# MARKUP
# PROMPT
# RETURNVALUE
# SGMLTAG
# TOKEN

# DATABASE
# HARDWARE
# INTERFACE
# MEDIALABEL
# SYSTEMITEM

sgml('<CITEREFENTRY>', sub { $skip_inline++ });
sgml('</CITEREFENTRY>', sub { $skip_inline-- });



########################################################################
#
# 'Block' elements 
#
########################################################################

sub para_start {
	output "\n" unless $newline_last++;

	if($_[0]->parent->ext->{'nobreak'}) {
		# Usually this is the FIRST element of
		# an @item, so we MUST not do a full
		# paragraph break.
		$_[0]->parent->ext->{'nobreak'} = 0;
	} else {
		output "\n";
	}
}

# Actually applies to a few other block elements as well
sub para_end {
	output "\n" unless $newline_last++; 
}

sgml('<PARA>', \&para_start);
sgml('<SIMPARA>', \&para_end);

texi_sgml('<EXAMPLE>', "\n\@unnumberedsubsubsec ");
texi_sgml('</EXAMPLE>', "\n\n");



########################################################################
#
# Verbatim displays. 
#
########################################################################

sub verbatim_on {
	texi_output("\n\n");
	texi_output("\@example\n") unless $no_collapase++;
}

sub verbatim_off {
	texi_output("\n\n");
	texi_output("\@end example\n") unless --$no_collapase;
}

texi_sgml('<PROGRAMLISTING>', \&verbatim_on); 
texi_sgml('</PROGRAMLISTING>', \&verbatim_off);
texi_sgml('<SCREEN>', \&verbatim_on); 
texi_sgml('</SCREEN>', \&verbatim_off);
texi_sgml('<LITERALLAYOUT>', \&verbatim_on); 
texi_sgml('</LITERALLAYOUT>', \&verbatim_off);
texi_sgml('<SYNOPSIS>', \&verbatim_on); 
texi_sgml('</SYNOPSIS>', \&verbatim_off);



########################################################################
#
# Admonitions and other 'outside flow'
#
########################################################################

## These are supposed to be set off from the text, so 
## proper indentation is not so important.
#
#sub admonition_end {
#	output "\n" unless $newline_last++;
#	output ".sp\n";
#}
#
#$admonition_end = *admonition_end{CODE};
#

# FIXME! Lotsa things!

#sgml('<NOTE>', "\n\n\@cartouche\nNote: ");
#sgml('</NOTE>', "\n\n\@end cartouche\n");
#sgml('<WARNING>', "\n\n\@cartouche\nWarning: ");
#sgml('</WARNING>', "\n\n\@end cartouche\n");
#sgml('<TIP>', "\n\n\@cartouche\nTip: ");
#sgml('</TIP>', "\n\n\@end cartouche\n");
#sgml('<CAUTION>', "\n\n\@cartouche\nCaution: ");
#sgml('</CAUTION>', "\n\n\@end cartouche\n");
#sgml('<IMPORTANT>', "\n\n\@cartouche\nImportant: ");
#sgml('</IMPORTANT>', "\n\n\@end cartouche\n");

#sgml('<NOTE>', sub {
#	output "\n" unless $newline_last++;
#	output ".PP\n";
#	output ".B Note: \n";
#	$listitem_first = 1;
#});
#sgml('</NOTE>', $admonition_end);




########################################################################
#
# Lists
#
########################################################################

texi_sgml('<VARIABLELIST>', "\n\@table \@asis\n");
texi_sgml('</VARIABLELIST>', "\n\@end table\n");
texi_sgml('<ORDEREDLIST>', "\n\@enumerate\n");
texi_sgml('</ORDEREDLIST>', "\n\@end enumerate\n");
texi_sgml('<ITEMIZEDLIST>', "\n\@itemize \@bullet\n");
texi_sgml('</ITEMIZEDLIST>', "\n\@end itemize\n");

sgml('<VARLISTENTRY>', sub { 
	$_[0]->ext->{'first_term'} = 1;
});

sgml('<TERM>', sub { 
	if($_[0]->parent->ext->{'first_term'}) {
		$_[0]->parent->ext->{'first_term'} = 0;
		texi_output "\n\n\@item ";
	} else {
		texi_output "\n\n\@itemx ";
	}
	save_cdata();
});
sgml('</TERM>', sub { 
	output fold_string(pop_output()) . "\n";
	$newline_last = 1;
	$raw_cdata--;
});

sgml('<LISTITEM>', sub {
	texi_output "\n\n\@item\n" unless $_[0]->in('VARLISTENTRY');
	$_[0]->ext->{'nobreak'} = 1;
});

sgml('<SIMPLELIST>', sub { 
	$_[0]->ext->{'first_member'} = 1;
});

sgml('<MEMBER>', sub {
	my $listtype = $_[0]->parent->attribute(TYPE)->value;
	
	if($listtype =~ /Inline/i) {
		if($_[0]->parent->ext->{'first_member'}) {
			# If this is the first member don't put any commas
			$_[0]->parent->ext->{'first_member'} = 0;
		} else {
			output ", ";
		}
	} elsif($listtype =~ /Vert/i) {
		texi_output("\n\n");
	}
});





########################################################################
#
# Stuff we don't know how to handle (yet) 
#
########################################################################

# Address blocks:

# Credit stuff:
# ACKNO
# ADDRESS
# AFFILIATION
# ARTPAGENUMS
# ATTRIBUTION
# AUTHORBLURB
# AUTHORGROUP
# OTHERCREDIT
# HONORIFIC

# Other document metadata:
# Element: BOOKINFO
# Element: RELEASEINFO



# DocInfo
# ArtHeader

# Areas:
# AREA
# AREASET
# AREASPEC


texi_sgml('<BEGINPAGE>', "\n\@page\n");

#BeginPage
#IndexTerm




########################################################################
#
# Linkage, cross references
#
########################################################################

## Print the URL
sgml('<ULINK>', sub {
	if($skip_inline++) { return; }	# hopefully doesn't happen
	output '@uref{', output $_[0]->attribute('URL'), ', '
});
sgml('</ULINK>', sub {
	output '}' unless --$skip_inline;
});

sgml('<XREF>', sub {
	my $id = $_[0]->attribute('LINKEND')->value;
	my ($nodename) = split(/,/, $Refs->get($id));

        if($nodename) {
		texi_output("\@xref\{$nodename\}");
	} else {
		$blank_xrefs++;
		texi_output "[XRef to $id]";
        }
});


# Anchor




########################################################################
#
# Other handlers 
#
########################################################################

sgml('|[lt    ]|', "<");
sgml('|[gt    ]|', ">");
sgml('|[amp   ]|', "&");

#
# Default handlers (uncomment these if needed).  Right now, these are set
# up to gag on any unrecognised elements, sdata, processing-instructions,
# or entities.
#
# sgml('start_element',sub { die "Unknown element: " . $_[0]->name; });
# sgml('end_element','');

sgml('cdata', sub
{ 
	for($_[0]) {
		s/\@/\@\@/g;
		s/\{/\@\{/g;
		s/\}/\@\}/g;
	}
	$newline_last = 0;
	output $_[0];
});

sgml('re', sub
{
	if($nocollapse_whitespace || !$newline_last) {
		output "\n";
	}

	$newline_last = 1;
});

sgml('re', "\n");
sgml('sdata',sub { die "Unknown SDATA: " . $_[0]; });
sgml('pi',sub { die "Unknown processing instruction: " . $_[0]; });
sgml('entity',sub { die "Unknown external entity: " . $_[0]->name; });
sgml('start_subdoc',sub { die "Unknown subdoc entity: " . $_[0]->name; });
sgml('end_subdoc','');
# sgml('conforming','');

1;

