<%class>
</%class>

<%init>
use Data::Dumper;

# my $mypath = $m->request_path();
# my $grp = 0;
# if ($mypath =~ /wae(\d+)/) {
#   $grp += $1;
# }

my $documents = $m->comp("/wae15/shared/db_access.mi",
    action => "read",
    params => {}
);

# NOTE(raoul): Here, I'm creating a `children` array for each document.
# Don't know if I could've done this more elegantly, it works though.
my %document_hierarchy = ();

# Add all documents to the document hierarchy.
foreach my $document (@$documents) {
  # First, add an array that will later hold all children of the document.
  $document->{"children"} = [];
  # Then, add the document to the hash.
  $document_hierarchy{$document->{"document_id"}} = $document;
}

# Push all child documents into the children arrays of their parents.
foreach my $document (@$documents) {
  if ($document->{"fk_parent_id"}) {
    push(@{$document_hierarchy{$document->{"fk_parent_id"}}->{"children"}}, $document);
  }
}

# Get all top-level documents.
my @top_level_documents = ();
foreach my $document (values %document_hierarchy) {
  # If parent id is not defined, then the document is top-level.
  if (!$document->{"fk_parent_id"}) {
    push(@top_level_documents, $document);
  }
}

</%init>

<div class="d-flex">
  <nav class="col-md-2 d-none d-md-block bg-light sidebar">
    <div class="sidebar-sticky">
      <ul class="nav flex-column nav-pills">
% foreach my $document (@top_level_documents) {
  <li class="nav-item">
      <a class="nav-link" href="/wae15/documents?document_id=<% $document->{"document_id"} %>"><% $document->{"title"} %></a>
      <& /wae15/shared/second_level_documents.mi,
        children => $document->{"children"}
      &>
  </li>
% }
      </ul>
    </div>
  </nav>
  <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
    <!-- Main content goes here -->
    <p>TODO(raoul): We've got the document hierarchy, now we just need to make it functional and maybe pretty.</p>
  </main>
</div>
