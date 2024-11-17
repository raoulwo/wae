<%class>
has 'grp' => (default => ($m->request_path() =~ /wae(\d+)/)?(0+$1):'?');
has 'maintitle' => (default => 'WAE Group');
</%class>

<%augment wrap>
  <html>
    <head>
      <meta charset="utf-8">
      <meta name="viewport" content="width=device-width, initial-scale=1">
      <link rel="stylesheet" href="static/css/base.css">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-QWTKZyjpPEjISv5WaRU9OFeRpok6YctnYmDr5pNlyT2bRjXh0JMhjY6hW+ALEwIH" crossorigin="anonymous">
      <script src="/static/js/ckeditor/ckeditor.js"></script>
% $.Defer {{
      <title><% $.maintitle %> <% $.grp %></title>
% }}
    </head>
    <body class="d-flex flex-column min-vh-100">
      <& /wae15/shared/header.mi, grp => $.grp &>
      <main class="container-fluid p-5">
      <% inner() %>
      </main>
      <& /wae15/shared/footer.mi, grp => $.grp &>

      <script src="https://cdn.jsdelivr.net/npm/@popperjs/core@2.11.8/dist/umd/popper.min.js" integrity="sha384-I7E8VVD/ismYTF4hNIPjVp/Zjvgyol6VFvRkX/vR+Vc4jQkC+hVqc2pM8ODewa9r" crossorigin="anonymous"></script>
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/js/bootstrap.min.js" integrity="sha384-0pUGZvbkm6XF6gxjEnlmuGrJXVbNuzT9qBBavbLwCsOGabYfZo0T0to5eqruptLy" crossorigin="anonymous"></script>
    </body>
  </html>
</%augment>

<%flags>
extends => undef
</%flags>
