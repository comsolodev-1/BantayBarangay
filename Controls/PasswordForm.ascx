<%@ Control Language="VB" AutoEventWireup="false" CodeFile="PasswordForm.ascx.vb" Inherits="PasswordForm" %>
<div class="card" style="max-width:460px">
    <h2>Change Password</h2>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    <div class="field">
        <label>Current password</label>
        <asp:TextBox ID="txtCurrent" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox>
    </div>
    <div class="field" style="margin-top:10px">
        <label>New password (at least 8 characters, letters and numbers)</label>
        <asp:TextBox ID="txtNew" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox>
    </div>
    <div class="field" style="margin-top:10px">
        <label>Confirm new password</label>
        <asp:TextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox>
    </div>
    <div style="margin-top:14px">
        <asp:Button ID="btnChange" runat="server" Text="Update Password" CssClass="btn" OnClick="btnChange_Click" />
    </div>
</div>
