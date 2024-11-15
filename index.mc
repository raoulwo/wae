<%class>
</%class>

<%init>
use Data::Dumper;

my $mypath = $m->request_path();
my $grp = 0;
if ($mypath =~ /wae(\d+)/) {
  $grp += $1;
}	

my $documents = $m->comp("/wae15/shared/db_access.mi",
    action => "read",
    params => {}
);

# TODO(raoul): We need to show the documents in the correct hierarchy
</%init>

Willkommen Gruppe <% $grp %>

<h1><a href="/wae15/editor">Create a new document</a></h1>

% foreach my $document (@$documents) {
  <%perl>
  # TODO(raoul): It should be possible to delete documents.
  my $document_id = $document->{"document_id"};
  my $query_string = $document_id ? "?document_id=$document_id" : undef;
  </%perl>
  <h1><% $document->{"title"} %></h1>
  <h2><a href="/wae15/documents<% $query_string %>">View document</a></h2>
  <h2><a href="/wae15/editor<% $query_string %>">Edit document</a></h2>
% }
