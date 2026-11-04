<%@ Control Language="VB" AutoEventWireup="false" CodeFile="PasswordForm.ascx.vb" Inherits="PasswordForm" %>
<bbui:Card runat="server">
    <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Change Password</asp:Label></p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="txtCurrent" Font-Bold="True">Current password</asp:Label><br />
        <asp:TextBox ID="txtCurrent" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox>
    </asp:Panel>
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="txtNew" Font-Bold="True">New password (at least 8 characters, letters and numbers)</asp:Label><br />
        <asp:TextBox ID="txtNew" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox>
    </asp:Panel>
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="txtConfirm" Font-Bold="True">Confirm new password</asp:Label><br />
        <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox>
    </asp:Panel>
    <asp:Panel runat="server">
        <asp:Button ID="btnChange" runat="server" Text="Update Password" OnClick="btnChange_Click" />
    </asp:Panel>
</bbui:Card>
