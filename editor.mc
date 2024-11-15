<%class>
  has 'document_id';
  has 'fk_parent_id';
  has 'title';
  has 'content' => (default => "<font face=Verdana>Bitte hier den Text eingeben.\n</font>\n");
  has 'save';
  has 'insert' => (default => 0);
</%class>

<h2>
% if (defined($.document_id) && $.insert == 0) {
  Dokument <% $.document_id %> editieren
% } else {
  Neues Dokument anlegen
% }
</h2>

% if (length($msg)) {
  <p style="color:red;font-size:10px;"><% $msg %></p>
% }

<form name="editform" method="post" enctype="application/x-www-form-urlencoded">
  <input type="hidden" name="document_id" value="<% $.document_id %>">
  <input type="hidden" name="insert" value="<% $.insert %>">

  <table width="100%" cellspacing=1 cellpadding=4 border=0>
    <colgroup>
      <col align="right" valign="top">
      <col align="left">
    </colgroup>

    <tr>
      <td>Titel:</td>
      <td><input type="text" name="title" value="<% $.title %>" size="50" /></td> <!-- Filter |h ?? -->
    </tr>

    <tr>
      <td>Parent-ID:</td>
      <td>
      <%doc>
      <%  $cgi->popup_menu(-name      =>'fk_parent_id',
	  -values    => [ sort keys %docTitleAndIds ],
	  -default   => $.fk_parent_id,
	  -labels    => \%docTitleAndIds)
      %> aktuell: <% $docTitleAndIds{$.fk_parent_id} %>
      </%doc>
      <input type="text" name="fk_parent_id" value="<% $.fk_parent_id %>" size="3" />

      </td>
    </tr>

    <tr>
      <td align=left colspan=2>
	<textarea name="content" id="content"><% $.content %></textarea>
	<script>
	  // Replace the <textarea id="content"> with a CKEditor instance, using default configuration.
	  CKEDITOR.replace('content', {
	    width: '560px',
	    height: '400px',
	  });
	</script>
	<br>
      </td>
    </tr>

    <tr>
      <td colspan=2 align=center>
	<br>
	<input type="submit" value="&Auml;nderungen speichern" name="save">
	&nbsp;&nbsp;&nbsp;
	<input type="reset" value="&Auml;nderungen verwerfen" name="Cancel"> <!-- onClick="window.close()" -->
	<br>
	<br>
      </td>
    </tr>
  </table>

</form>

<%init>
use Data::Dumper;
use CGI;

my $dbh = Ws24::DBI->dbh();
my $cgi = new CGI;

my $msg = "Welcome to the WCM content editor.";
my %docTitleAndIds = ('0', 'top level document');

my $sth = $dbh->prepare("SELECT document_id, title from group15_documents");
$sth->execute();
while (my $res = $sth->fetchrow_hashref()) {
  $docTitleAndIds{$res->{document_id}} = $res->{title};
}

if ($.save) {
# Speichern wurde gedrückt...
  if ($.insert == 1) {
  # Datensatz aus Formularfeldern in Datenbank einfügen
    my $sth = $dbh->prepare("INSERT INTO group15_documents (document_id,content,title,fk_parent_id,created_at) values (?,?,?,?,NOW())");
    $sth->execute($.document_id,$.content,$.title,(($.fk_parent_id > 0)?$.fk_parent_id:0));
    $msg = "Datensatz ". $.document_id ." neu in DB aufgenommen.".$sth->rows();
#    $.insert(0);
  } else {
  # Datensatz in Datenbank ändern
    my $sth = $dbh->prepare("UPDATE group15_documents SET content = ?, title = ?, fk_parent_id = ? WHERE document_id = ?");
    $sth->execute($.content,$.title,$.fk_parent_id,$.document_id);
    $msg = "Datensatz " . $.document_id ." in DB ver&auml;ndert.".$sth->rows();
  }
} elsif ($.document_id) {
# id erkannt, daten aus Datenbank lesen
  my $sth = $dbh->prepare("SELECT document_id, title, content, created_at, fk_parent_id, from group15_documents WHERE document_id = ?");
  $sth->execute($.document_id);
  my $res = $sth->fetchrow_hashref();
  $.content($res->{content} || $.content);
  $.title($res->{title});
  $.fk_parent_id($res->{fk_parent_id});
  $msg = "Datensatz " . $.document_id . " aus DB gelesen.".((defined($res) && scalar(keys(%$res)))?1:0);
} else {
# keine ID, neues Dokument erstellen
  my $sth = $dbh->prepare("SELECT max(document_id) as max_document_id FROM group15_documents");
  $sth->execute();
  my $res = $sth->fetchrow_hashref();
  $.document_id($res->{max_document_id}+1);
  $.insert(1);
}
</%init>
