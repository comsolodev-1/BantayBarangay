<%@ Control Language="VB" AutoEventWireup="false" CodeFile="PasswordForm.ascx.vb" Inherits="PasswordForm" %>
<bbui:Card runat="server" ContentPadding="18" CssClass="password-card">
    <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Change Password</asp:Label></p>
    <bbui:FieldRow runat="server" Columns="1" RowGapPixels="16">
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="txtCurrent" Font-Bold="True">Current password</asp:Label><br />
        <bbui:FormTextBox ID="txtCurrent" runat="server" TextMode="Password" MaxLength="100" autocomplete="current-password" />
    </asp:Panel>
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="txtNew" Font-Bold="True">New password</asp:Label><br />
        <bbui:FormTextBox ID="txtNew" runat="server" TextMode="Password" MaxLength="100" autocomplete="new-password" aria-describedby="password-hint" />
        <small id="password-hint">Use at least 8 characters, including letters and numbers.</small>
    </asp:Panel>
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="txtConfirm" Font-Bold="True">Confirm new password</asp:Label><br />
        <bbui:FormTextBox ID="txtConfirm" runat="server" TextMode="Password" MaxLength="100" autocomplete="new-password" />
    </asp:Panel>
    <asp:Panel runat="server" CssClass="password-actions">
        <bbui:ActionButton ID="btnChange" runat="server" Text="Update Password" OnClick="btnChange_Click" />
    </asp:Panel>
    </bbui:FieldRow>
</bbui:Card>
<bbui:Workflow ID="pnlFeedback" runat="server" Visible="false" EnableViewState="false">
    <bbui:DialogTitle runat="server"><asp:Literal ID="litFeedbackTitle" runat="server" /></bbui:DialogTitle>
    <asp:Literal ID="litMessage" runat="server" />
    <bbui:DialogFooter runat="server"><bbui:ActionButton runat="server" Text="Close" SkinID="Secondary" CausesValidation="false" /></bbui:DialogFooter>
</bbui:Workflow>
