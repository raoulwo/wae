<%class>
  has 'document_id';
  has 'fk_parent_id';
  has 'title';
  has 'content' => (default => "<font face=Verdana>Bitte hier den Text eingeben.\n</font>\n");
  has 'metatext';
  has 'save';
  has 'insert' => (default => 0);
</%class>

<h2>
% if (defined($.document_id) && ($.insert==0)) {
Dokument <% $.document_id %> editieren
% } else {
Neues Dokument anlegen
% }
</h2>
% if (length($msg)) {
<p style="color:red;font-size:10px;"><% $msg %></p>
% }
<form name="editform"
method="post" enctype="application/x-www-form-urlencoded">

<input type="hidden" name="document_id" value="<% $.document_id %>">
<input type="hidden" name="insert" value="<% $.insert %>">

<TABLE WIDTH="100%" CELLSPACING=1 CELLPADDING=4 BORDER=0>
<COLGROUP>
<COL ALIGN="right" VALIGN="top">
<COL ALIGN="left">
</COLGROUP>
<TR>
<TD>Titel:</TD>
<TD><input type="text" name="title" value="<% $.title %>" size="50" /></TD> <!-- Filter |h ?? -->
</TR>

<TR>
<TD>Parent-ID:</TD>
<TD>
<%doc>
<%  $cgi->popup_menu(-name      =>'fk_parent_id',
                       -values    => [ sort keys %docTitleAndIds ],
                       -default   => $.fk_parent_id,
                       -labels    => \%docTitleAndIds)
  %> aktuell: <% $docTitleAndIds{$.fk_parent_id} %>
</%doc>
  <input type="text" name="fk_parent_id" value="<% $.fk_parent_id %>" size="3" />

</TD>
</TR>
<TR>
<TD ALIGN=left COLSPAN=2>
  <textarea name="content" id="content"><% $.content %></textarea>
<script>
	// Replace the <textarea id="content"> with a CKEditor
	// instance, using default configuration.
	CKEDITOR.replace('content',{
		width   : '560px',
		height  : '400px'
	});
</script>
<BR>
</TD>
</TR>

<TR>
<TD COLSPAN=2 ALIGN=center>
<BR>
<input type="submit" value="&Auml;nderungen speichern" name="save">
&nbsp;&nbsp;&nbsp;
<input type="reset" value="&Auml;nderungen verwerfen" name="Cancel"> <!-- onClick="window.close()" -->
<BR>
<BR>
</TD>
</TR>
</TABLE>

</form>

<%init>
use Data::Dumper;
use CGI;

my $dbh = Ws24::DBI->dbh();
my $cgi = new CGI;

my $msg = "Welcome to the WCM content editor.";
my %docTitleAndIds = ('0', 'top level document');

my $sth = $dbh->prepare("SELECT document_id, title from schranz_cms");
$sth->execute();
while (my $res = $sth->fetchrow_hashref()) {
  $docTitleAndIds{$res->{document_id}} = $res->{title};
}

if ($.save) {
# Speichern wurde gedrückt...
  if ($.insert == 1) {
  # Datensatz aus Formularfeldern in Datenbank einfügen
    my $sth = $dbh->prepare("INSERT INTO schranz_cms (document_id,content,metatext,title,parent,created) values (?,?,?,?,?,NOW())");
    $sth->execute($.document_id,$.content,$.metatext,$.title,(($.fk_parent_id > 0)?$.fk_parent_id:0));
    $msg = "Datensatz ". $.document_id ." neu in DB aufgenommen.".$sth->rows();
#    $.insert(0);
  } else {
  # Datensatz in Datenbank ändern
    my $sth = $dbh->prepare("UPDATE schranz_cms SET content = ?, title = ?, parent = ? WHERE document_id = ?");
    $sth->execute($.content,$.title,$.fk_parent_id,$.document_id);
    $msg = "Datensatz " . $.document_id ." in DB ver&auml;ndert.".$sth->rows();
  }
} elsif ($.document_id) {
# id erkannt, daten aus Datenbank lesen
  my $sth = $dbh->prepare("SELECT document_id, title, content, created, parent, metatext from schranz_cms WHERE document_id = ?");
  $sth->execute($.document_id);
  my $res = $sth->fetchrow_hashref();
  $.content($res->{content} || $.content);
  $.title($res->{title});
  $.fk_parent_id($res->{parent});
  $msg = "Datensatz " . $.document_id . " aus DB gelesen.".((defined($res) && scalar(keys(%$res)))?1:0);
} else {
# keine ID, neues Dokument erstellen
  my $sth = $dbh->prepare("SELECT max(document_id) as maxdocid FROM schranz_cms");
  $sth->execute();
  my $res = $sth->fetchrow_hashref();
  $.document_id($res->{maxdocid}+1);
  $.insert(1);
}
</%init>
