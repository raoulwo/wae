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

<h1><% $document->{"title"} %></h1>
<h1><% $document->{"created_at"} %></h1>
<h1><% $document->{"content"} %></h1>


% if( defined $m->session->{user_id} ) {
  <div class="col-md-2">
    <a class="btn btn-primary active w-100 mb-3" href="/wae15/editor?document_id=<% $document->{"document_id"} %>">Edit document</a>

    <form name="deleteform" method="post">
        <input type="hidden" name="document_id" value="<% $.document_id %>">
        <input type="submit" name="delete" value="Delete document" class="btn btn-dark w-100">
    </form>
  </div>
% } else {
  <p>You need to be logged in to edit or delete documents.</p>
% }
