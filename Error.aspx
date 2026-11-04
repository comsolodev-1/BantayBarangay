<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Error.aspx.vb" Inherits="ErrorPage" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <title>Something went wrong</title>
</head>
<body bgcolor="#1A3D28">
    <form id="form1" runat="server">
        <asp:Panel runat="server">
            <asp:Table runat="server" SkinID="SignIn" role="presentation"><asp:TableRow><asp:TableCell><bbui:Card runat="server">
                <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Something went wrong</asp:Label></p>
                <p>The page could not be shown. Please go back and try again.</p>
                <asp:HyperLink runat="server" NavigateUrl="~/Default.aspx">Back to Home</asp:HyperLink>
            </bbui:Card></asp:TableCell></asp:TableRow></asp:Table>
        </asp:Panel>
    </form>
</body>
</html>
