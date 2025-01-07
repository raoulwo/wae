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

# Sort top-level documents alphabetically by title
@top_level_documents = sort { lc($a->{"title"}) cmp lc($b->{"title"}) } @top_level_documents;

# Sort all documents by date added (created_at)
@$documents = sort { $b->{"created_at"} cmp $a->{"created_at"} } @$documents;

</%init>

<div class="d-flex">
  <nav class="col-md-2 d-none d-md-block bg-light sidebar">
    <div class="sidebar-sticky">
      <ul class="nav flex-column nav-pills">
% foreach my $document (@top_level_documents) {
  <li class="nav-item dropdown">
    <a class="nav-link dropdown-toggle" data-toggle="dropdown" href="#" role="button" aria-haspopup="true" aria-expanded="false"><% $document->{"title"} %></a>
    <div class="dropdown-menu">
      <a class="dropdown-item" href="/wae15/documents?document_id=<% $document->{"document_id"} %>"><% $document->{"title"} %></a>
% if (@{$document->{"children"}} > 0) {   
   <div class="dropdown-divider"></div>
      <& /wae15/shared/second_level_documents.mi,
        children => $document->{"children"}
      &>
% }
    </div>
  </li>
% }
      </ul>
    </div>
  </nav>
  <main role="main" class="col-md-9 ml-sm-auto col-lg-10 px-4">
    <!-- Main content goes here -->
    <div class="row justify-content-center">
    <div class="document-preview col-md-8">
% foreach my $document (@$documents) {
      <div class="card mb-3">
        <div class="card-body">
          <h5><a href="/wae15/documents?document_id=<% $document->{"document_id"} %>"><% $document->{"title"} %></a></h5>
          <hr>
          <p class="card-text text-truncate-max-height">
% my $text_content = $document->{"content"};
% $text_content =~ s/<[^>]*>//g; # Remove HTML tags
% my @lines = split /\n/, $text_content;
% my $preview = join "\n", @lines[0..1];
<% $preview %> ...
        </p>
        </div>
</div>
% }
    </div>
    </div>
  </main>
</div>

<script src="https://code.jquery.com/jquery-3.3.1.slim.min.js" integrity="sha384-q8i/X+965DzO0rT7abK41JStQIAqVgRVzpbzo5smXKp4YfRvH+8abtTE1Pi6jizo" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/popper.js@1.14.7/dist/umd/popper.min.js" integrity="sha384-UO2eT0CpHqdSJQ6hJty5KVphtPhzWj9WO1clHTMGa3JDZwrnQq4sF86dIHNDz0W1" crossorigin="anonymous"></script>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.3.1/dist/js/bootstrap.min.js" integrity="sha384-JjSmVgyd0p3pXB1rRibZUAYoIIy6OrQ6VrjIEaFf/nJGzIxFDsf4x0xIM+B07jRM" crossorigin="anonymous"></script>
