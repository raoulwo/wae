Willkommen Gruppe <% $grp %>

<a href="./comps/wae15/editor">Editor</a>

<%init>
use Data::Dumper;

my $mypath = $m->request_path();
my $grp = 0;
if ($mypath =~ /wae(\d+)/) {
  $grp += $1;
}	
</%init>
