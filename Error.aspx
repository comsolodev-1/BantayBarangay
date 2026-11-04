<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Error.aspx.vb" Inherits="ErrorPage" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title>Something went wrong</title>
</head>
<body>
    <form id="form1" runat="server">
        <asp:Panel runat="server">
            <asp:Table runat="server" SkinID="SignIn" role="presentation"><asp:TableRow><asp:TableCell>
                <h1>Something went wrong</h1>
                <p>The page could not be shown. Please go back and try again.</p>
                <asp:HyperLink runat="server" NavigateUrl="~/Default.aspx">Back to Home</asp:HyperLink>
            </asp:TableCell></asp:TableRow></asp:Table>
        </asp:Panel>
    </form>
</body>
</html>
