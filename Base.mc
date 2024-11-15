<%class>
has 'grp' => (default => ($m->request_path() =~ /wae(\d+)/)?(0+$1):'?');
has 'maintitle' => (default => 'WAE Group');
</%class>

<%augment wrap>
  <html>
    <head>
      <link rel="stylesheet" href="static/css/style.css">
      <script src="/static/js/ckeditor/ckeditor.js"></script>
% $.Defer {{
      <title><% $.maintitle %> <% $.grp %></title>
% }}
    </head>
    <body>
      <% inner() %>
      <& footer.mi, grp => $.grp &>
    </body>
  </html>
</%augment>

<%flags>
extends => undef
</%flags>
