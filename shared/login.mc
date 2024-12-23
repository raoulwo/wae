<%class>
  has 'username';
  has 'password';
</%class>

% if (defined $m->session->{user_id} && $m->session->{user_id}) {
  <& logindone.mi &>
% } else {
  <& loginform.mi, username=>$.username, password=>$.password &>
% }

<%init>
        my $dbh = Ws24::DBI->dbh();
        my $sth = $dbh->prepare("SELECT user_id FROM group15_user WHERE username=? AND password=?");
        $sth->execute($.username, $.password);
  my $user = $sth->fetchrow_hashref;

  if (defined $user->{'user_id'} && $user->{'user_id'} > 0) {
    $m->session->{user_id} = $user->{'user_id'};
  }
</%init>