<%class>
  has 'document_id';
  has 'fk_parent_id';
  has 'title';
  has 'content' => (default => "<font face=Verdana>Bitte hier den Text eingeben.\n</font>\n");
  has 'save';
  has 'insert' => (default => 0);
</%class>

<%init>
use Data::Dumper;
use CGI;

my $dbh = Ws24::DBI->dbh();
my $cgi = new CGI;

my $msg = "Welcome to the WCM content editor.";
my %docTitleAndIds = ('0', 'top level document');

# Fetch all documents.
my $documents = $m->comp("/wae15/shared/db_access.mi",
  action => "read",
  params => {}
);
foreach my $document (@$documents) {
  $docTitleAndIds{$document->{document_id}} = $document->{title};
}

if ($.save) {
# Speichern wurde gedrückt...
  if ($.insert == 1) {
  # Datensatz aus Formularfeldern in Datenbank einfügen
    my $new_document_id = $m->comp("/wae15/shared/db_access.mi",
      action => "create",
      params => {
        title => $.title,
        content => $.content,
        fk_parent_id => $.fk_parent_id || undef
      }
    );
    $msg = "Datensatz " . $new_document_id . " neu in DB aufgenommen.";

    # TODO(raoul): Maybe redirect to document view after creating it?

#    $.insert(0);
  } else {
  # Datensatz in Datenbank ändern
    my $sth = $dbh->prepare("UPDATE group15_documents SET content = ?, title = ?, fk_parent_id = ? WHERE document_id = ?");
    $sth->execute($.content,$.title,$.fk_parent_id || undef,$.document_id);
    $msg = "Datensatz " . $.document_id ." in DB ver&auml;ndert.".$sth->rows();
  }
} elsif ($.document_id) {
# id erkannt, daten aus Datenbank lesen
  my $sth = $dbh->prepare("SELECT document_id, title, content, created_at, fk_parent_id from group15_documents WHERE document_id = ?");
  $sth->execute($.document_id);
  my $res = $sth->fetchrow_hashref();
  $.content($res->{content} || $.content);
  $.title($res->{title});
  $.fk_parent_id($res->{fk_parent_id});
  $msg = "Datensatz " . $.document_id . " aus DB gelesen.".((defined($res) && scalar(keys(%$res)))?1:0);

  # TODO(raoul): Maybe redirect to document view after updating it?

} else {
# keine ID, neues Dokument erstellen
  #my $sth = $dbh->prepare("SELECT max(document_id) as max_document_id FROM group15_documents");
  #$sth->execute();
  #my $res = $sth->fetchrow_hashref();
  #$.document_id($res->{max_document_id}+1);
  $.insert(1);
}

</%init>

<%perl>
my $page_title = "Neues Dokument anlegen";
if (defined($.document_id) && $.insert == 0) {
  $page_title = "Dokument " . $.document_id . " editieren";
}
</%perl>

<div class="d-flex flex-row">
  <section class="me-5" style="width: 768px;">
    <h2><% $page_title %></h2>

% if (length($msg)) {
  <p style="color:red;font-size:10px;"><% $msg %></p>
% }

    <form name="editform" method="post" enctype="application/x-www-form-urlencoded">
      <input type="hidden" name="document_id" value="<% $.document_id %>">
      <input type="hidden" name="insert" value="<% $.insert %>">

      <div class="mb-3">
	<label for="title">Titel</label>
	<input type="text" name="title" value="<% $.title %>" size="50">
      </div>

      <div class="mb-3">
        <label for="fk_parent_id">Parent ID</label>
	<%  $cgi->popup_menu(
	    -name      =>'fk_parent_id',
	    -values    => [ sort keys %docTitleAndIds ],
	    -default   => $.fk_parent_id,
	    -labels    => \%docTitleAndIds)
	%>
	<span>Aktuell: <% $docTitleAndIds{$.fk_parent_id} %></span>
      </div>

      <textarea name="content" id="content"><% $.content %></textarea>
      <script>
	// Replace the <textarea id="content"> with a CKEditor instance, using default configuration.
	CKEDITOR.replace('content', {
	  width: '560px',
	  height: '400px',
	});
      </script>

      <div class="d-flex justify-content-start mt-3">
	<input class="me-3" type="submit" value="&Auml;nderungen speichern" name="save">
	<input type="reset" value="&Auml;nderungen verwerfen" name="Cancel"> <!-- onClick="window.close()" -->
      </div>

    </form>

  </section>
  <section class="flex-grow-1">
    <h2>Document Preview</h2>
    <p>TODO(raoul): Implement the document preview</p>
  </section>
</div>
