<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Login.aspx.vb" Inherits="Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sign In - Bantay Barangay</title>
</head>
<body>
    <form id="form1" runat="server" defaultbutton="btnLogin">
        <asp:Panel runat="server">
            <asp:Table runat="server" SkinID="SignIn" role="presentation"><asp:TableRow><asp:TableCell>
                <asp:Panel runat="server" HorizontalAlign="Center">
                    <asp:Image runat="server" ImageUrl="~/Content/dilg-logo.png" AlternateText="DILG" Height="56px" />
                    <asp:Image runat="server" ImageUrl="~/Content/talisay-logo.png" AlternateText="Talisay" Height="56px" />
                </asp:Panel>
                <h1>Bantay Barangay</h1>
                <p>DILG Municipal Office of Talisay, Camarines Norte</p>
                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                <asp:Panel runat="server">
                    <asp:Label runat="server" AssociatedControlID="txtUsername" Font-Bold="True">Username</asp:Label><br />
                    <asp:TextBox ID="txtUsername" runat="server" MaxLength="50" autocomplete="username"></asp:TextBox>
                </asp:Panel>
                <asp:Panel runat="server">
                    <asp:Label runat="server" AssociatedControlID="txtPassword" Font-Bold="True">Password</asp:Label><br />
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100" autocomplete="current-password"></asp:TextBox>
                </asp:Panel>
                <asp:Panel runat="server" hidden="hidden" aria-hidden="true">
                    <asp:TextBox ID="txtWebsite" runat="server" TabIndex="-1" autocomplete="off"></asp:TextBox>
                </asp:Panel>
                <asp:Panel runat="server">
                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" Width="100%" OnClick="btnLogin_Click" />
                </asp:Panel>
                <p><asp:HyperLink runat="server" NavigateUrl="~/Default.aspx">Continue as viewer (no login)</asp:HyperLink></p>
            </asp:TableCell></asp:TableRow></asp:Table>
        </asp:Panel>
    </form>
</body>
</html>
