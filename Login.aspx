<%@ Page Language="VB" AutoEventWireup="false" CodeFile="Login.aspx.vb" Inherits="Login" %>
<!DOCTYPE html>
<html lang="en">
<head runat="server">
    <meta charset="utf-8" />
    <meta name="viewport" content="width=device-width, initial-scale=1" />
    <title>Sign In - Bantay Barangay</title>
    <link href="~/Content/site.css" rel="stylesheet" />
</head>
<body>
    <form id="form1" runat="server" defaultbutton="btnLogin">
        <div class="login-wrap">
            <div class="login-card">
                <div class="logos">
                    <img src="<%= ResolveUrl("~/Content/dilg-logo.png") %>" alt="DILG" />
                    <img src="<%= ResolveUrl("~/Content/talisay-logo.png") %>" alt="Talisay" />
                </div>
                <h1>Bantay Barangay</h1>
                <p class="sub">DILG Municipal Office of Talisay, Camarines Norte</p>
                <asp:Literal ID="litMessage" runat="server"></asp:Literal>
                <div class="field">
                    <label for="txtUsername">Username</label>
                    <asp:TextBox ID="txtUsername" runat="server" MaxLength="50" autocomplete="username"></asp:TextBox>
                </div>
                <div class="field" style="margin-top:10px">
                    <label for="txtPassword">Password</label>
                    <asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100" autocomplete="current-password"></asp:TextBox>
                </div>
                <div class="hp" aria-hidden="true">
                    <asp:TextBox ID="txtWebsite" runat="server" TabIndex="-1" autocomplete="off"></asp:TextBox>
                </div>
                <div style="margin-top:16px">
                    <asp:Button ID="btnLogin" runat="server" Text="Sign In" CssClass="btn" Width="100%" OnClick="btnLogin_Click" />
                </div>
                <p class="sub" style="margin-top:14px"><a href="<%= ResolveUrl("~/Default.aspx") %>">Continue as viewer (no login)</a></p>
            </div>
        </div>
    </form>
</body>
</html>
