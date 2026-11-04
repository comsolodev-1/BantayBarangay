<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Error.aspx.vb" Inherits="ErrorPage" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title>Something went wrong</title>
    <link href="~/Content/site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server">
        <div class="login-wrap">
            <div class="login-card">
                <h1>Something went wrong</h1>
                <p class="sub">The page could not be shown. Please go back and try again.</p>
                <a class="btn" href="<%= ResolveUrl("~/Default.aspx") %>">Back to Home</a>
            </div>
        </div>
    </form>
</body>
</html>
