<%class>
has 'document_id';
has 'delete';
</%class>

<%init>
# Get the document record by its id.
my $documents = $m->comp("/wae15/shared/db_access.mi",
  action => "read",
  params => {
    document_id => $.document_id
  }
);
my $document = @$documents[0];

# TODO(raoul): Maybe redirect to the main page after deleting the document?

# Delete the document.
if ($.delete) {
    $m->comp("/wae15/shared/db_access.mi",
        action => "delete",
        params => {
            document_id => $.document_id
        }
    );
    # Redirect to the main page after deletion
    $m->redirect('/wae15/index');
}
</%init>

<p>TODO(raoul): Finish the document view, do some styling maybe add the children?</p>

<div class="col-8 mx-auto">
  <div class="card">
    <div class="card-body">
      <h5 class="card-title"><% $document->{"title"} %></h5>
      <h6 class="card-subtitle mb-2 text-muted"><% $document->{"created_at"} %></h6>
      <p class="card-text"><% $document->{"content"} %></p>
    </div>
    <div class="card-footer">
% if( defined $m->session->{user_id} ) {
  <div class="d-flex justify-content-end align-items-center">
  <a class="btn btn-primary active mb-3 mr-2" href="/wae15/editor?document_id=<% $document->{"document_id"} %>">Edit document</a>

  <form name="deleteform" method="post">
    <input type="hidden" name="document_id" value="<% $.document_id %>">
    <input type="submit" name="delete" value="Delete document" class="btn btn-dark mr-2">
  </form>
  </div>
% } else {
<p>You need to be logged in to edit or delete documents.</p>
% }
  </div>
</div>
