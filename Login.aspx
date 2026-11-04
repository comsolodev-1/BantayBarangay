<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Login.aspx.vb" Inherits="Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sign In - Bantay Barangay</title>
</head>
<body bgcolor="#1A3D28">
    <form id="form1" runat="server" defaultbutton="btnLogin">
        <asp:Panel runat="server" Height="40px" />
        <asp:Panel runat="server">
            <asp:Table runat="server" SkinID="SignIn" role="presentation"><asp:TableRow><asp:TableCell><bbui:Card runat="server">
                <asp:Panel runat="server" HorizontalAlign="Center">
                    <asp:Image runat="server" ImageUrl="~/Content/dilg-logo.png" AlternateText="DILG" Height="56px" />
                    <asp:Image runat="server" ImageUrl="~/Content/talisay-logo.png" AlternateText="Talisay" Height="56px" />
                </asp:Panel>
                <p align="center"><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Bantay Barangay</asp:Label></p>
                <p align="center">DILG Municipal Office of Talisay, Camarines Norte</p>
                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                <asp:Table runat="server" Width="100%" CellPadding="6" CellSpacing="0" role="presentation">
                    <asp:TableRow><asp:TableCell>
                        <asp:Label runat="server" AssociatedControlID="txtUsername" Font-Bold="True">Username</asp:Label><br />
                        <asp:TextBox ID="txtUsername" runat="server" MaxLength="50" autocomplete="username" Width="98%" />
                    </asp:TableCell></asp:TableRow>
                    <asp:TableRow><asp:TableCell>
                        <asp:Label runat="server" AssociatedControlID="txtPassword" Font-Bold="True">Password</asp:Label><br />
                        <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100" autocomplete="current-password" Width="98%" />
                    </asp:TableCell></asp:TableRow>
                    <asp:TableRow><asp:TableCell>
                        <asp:Panel runat="server" hidden="hidden" aria-hidden="true">
                            <asp:TextBox ID="txtWebsite" runat="server" TabIndex="-1" autocomplete="off" />
                        </asp:Panel>
                        <asp:Button ID="btnLogin" runat="server" Text="Sign In" Width="100%" OnClick="btnLogin_Click" />
                    </asp:TableCell></asp:TableRow>
                </asp:Table>
                <p align="center"><asp:HyperLink runat="server" NavigateUrl="~/Default.aspx">Continue as viewer (no login)</asp:HyperLink></p>
            </bbui:Card></asp:TableCell></asp:TableRow></asp:Table>
        </asp:Panel>
    </form>
</body>
</html>
