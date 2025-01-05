<%class>
  has 'document_id';
  has 'fk_parent_id';
  has 'title';
  has 'content' => (default => "<font face=Verdana>Please enter text here.\n</font>\n");
  has 'save';
  has 'insert' => (default => 0);
</%class>

<%init>
# Only allow editing when logged in
if( !defined $m->session->{user_id} ) {
  $m->redirect('/wae15/index');
}

use Data::Dumper;
use CGI;

my $dbh = Ws24::DBI->dbh();
my $cgi = new CGI;

my $msg = "Welcome to the WCM content editor.";
my %docTitleAndIds = ('0', 'Top Level Document');
my %originalText = "Original text";

# Fetch all documents.
my $documents = $m->comp("/wae15/shared/db_access.mi",
  action => "read",
  params => {}
);
foreach my $document (@$documents) {
  $docTitleAndIds{$document->{document_id}} = $document->{title};
}

if ($.save) {
# Speichern wurde gedr�ckt...
  if ($.insert == 1) {
  # Datensatz aus Formularfeldern in Datenbank einf�gen
    my $new_document_id = $m->comp("/wae15/shared/db_access.mi",
      action => "create",
      params => {
        title => $.title,
        content => $.content,
        fk_parent_id => $.fk_parent_id || undef
      }
    );
    $msg = "Article " . $new_document_id . " saved in the DB successfully.";

    # Redirect to the article after creating it.
    $m->redirect('/wae15/documents?document_id='. $new_document_id);

#    $.insert(0);
  } else {
  # Datensatz in Datenbank �ndern
    my $sth = $dbh->prepare("UPDATE group15_documents SET content = ?, title = ?, fk_parent_id = ? WHERE document_id = ?");
    $sth->execute($.content,$.title,$.fk_parent_id || undef,$.document_id);
    $msg = "Article " . $.document_id ." updated in the DB successfully. (".$sth->rows() . ")";

    # Redirect to the article after updating it.
    # Note: This is commented out because it redirects instantly after saving.
    #$m->redirect('/wae15/documents?document_id='. $.document_id);
  }
} elsif ($.document_id) {
# id erkannt, daten aus Datenbank lesen
  my $sth = $dbh->prepare("SELECT document_id, title, content, created_at, fk_parent_id from group15_documents WHERE document_id = ?");
  $sth->execute($.document_id);
  my $res = $sth->fetchrow_hashref();
  $.content($res->{content} || $.content);
  $.title($res->{title});
  $.fk_parent_id($res->{fk_parent_id});
  $msg = "Article " . $.document_id . " loaded from the DB.";

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
my $page_title = "Create a New Article";
if (defined($.document_id) && $.insert == 0) {
  $page_title = "Edit Document No. " . $.document_id;
}
</%perl>

<div class="container col-5 d-flex justify-content-center">
  <section class="me-5" style="width: 768px;">
    <h2 class="text-center"><% $page_title %></h2>

% if (length($msg)) {
  <div class="alert alert-info" role="alert">
    <% $msg %>
  </div>
% }

    <form name="editform" method="post" enctype="application/x-www-form-urlencoded">
      <input type="hidden" name="document_id" value="<% $.document_id %>">
      <input type="hidden" name="insert" value="<% $.insert %>">

      <div class="form-group mb-3">
        <label for="title">Titel</label>
        <input class="form-control" type="text" name="title" value="<% $.title %>" size="50">
      </div>

      <div class="form-group mb-3">
        <label for="fk_parent_id">Parent ID</label>
          <%  $cgi->popup_menu(
              -name      =>'fk_parent_id',
              -values    => [ sort keys %docTitleAndIds ],
              -default   => $.fk_parent_id,
              -labels    => \%docTitleAndIds,
              -class     => 'form-control'),
          %>
      </div class>
% if (length($docTitleAndIds{$.fk_parent_id})) {
  <div class="form-group mb-3 alert alert-info" role="alert">
        <span>Currently: <% $docTitleAndIds{$.fk_parent_id} %></span>
  </div>
% } else {
  <div class="alert alert-info" role="alert">
    <span>New article will be saved under the current article (Parent ID).</span>
  </div>
% }
      <div class="form-group mb-3">
        <textarea name="content" id="content"><% $.content %></textarea>
      </div>
      <script>
        // Replace the <textarea id="content"> with a CKEditor instance, using default configuration.
        CKEDITOR.replace('content', {
          width: '100%',
          height: '400px',
        });
      </script>
      <div class="form-group col-md-8 mb-3 mx-auto">
        <div class="row mb-1">
        <input class="btn btn-primary" type="submit" value="Save Changes" name="save">
        </div>
        <div class="row">
          <input class="btn btn-danger" type="reset" value="Cancel Changes" name="Cancel" onClick="CKEDITOR.instances.content.setData(<% %originalText %>, function() { this.updateElement(); } )"> <!-- onClick="window.close()" -->
        </div>
      </div>
    </form>

  </section>
</div>