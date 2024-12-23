<!-- <div id="contents">
        <div id="leftcontainer">
-->
                <h2 class="mainheading">
                        You have been logged out!
                </h2>
                <section>

<%init>
  # Clear the user_id session variable to log out the user.
  undef($m->session->{user_id});

  # Set the HTTP Refresh header to refresh the page
  $m->redirect($m->req->uri);
</%init>