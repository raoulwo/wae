<%class>
  has 'refresh' => (default => 1);
</%class>

<div class="container col-5 d-flex justify-content-center">
        <h2>
                You have been logged out!
        </h2>
</div>

<%init>
  # Clear the user_id session variable to log out the user.
  undef($m->session->{user_id});

  if($.refresh) {
        $m->redirect('/wae15/shared/logout?refresh='. 0);
  }
</%init>
