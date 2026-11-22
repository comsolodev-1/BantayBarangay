<%@ Page Title="Accounts" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Accounts.aspx.vb" Inherits="Super_Accounts" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Accounts</asp:Label></p>
            <p>Create and manage Barangay Admin accounts. Each barangay has one admin account.</p>
        </asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ New Account" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlForm" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Create Barangay Admin Account</asp:Label></p>
        <asp:Literal ID="litAvailability" runat="server" />
        <p>Role: Barangay Admin</p>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay *</asp:Label><br />
                <bbui:FormSelect ID="ddlBarangay" runat="server"></bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtUsername" Font-Bold="True">Username *</asp:Label><br /><bbui:FormTextBox ID="txtUsername" runat="server" MaxLength="50"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtPassword" Font-Bold="True">Initial password *</asp:Label><br /><bbui:FormTextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtDisplayName">Name</asp:Label>
                <bbui:FormTextBox ID="txtDisplayName" runat="server" MaxLength="100" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlNewStatus">Status</asp:Label>
                <bbui:FormSelect ID="ddlNewStatus" runat="server">
                    <asp:ListItem>Active</asp:ListItem>
                    <asp:ListItem>Inactive</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContact" Font-Bold="True">Contact number</asp:Label><br /><bbui:FormTextBox ID="txtContact" runat="server" MaxLength="15"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <footer class="dialog-footer">
            <bbui:ActionButton
                ID="btnSave"
                runat="server"
                Text="Create Account"
                data-confirm="Create Account?"
                OnClick="btnSave_Click" />
            <bbui:ActionButton
                ID="btnCancel"
                runat="server"
                Text="Cancel"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancel_Click" />
        </footer>
    </bbui:Card>

    <bbui:Card ID="pnlReset" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Reset Password</asp:Label></p>
        <asp:HiddenField ID="hfResetUserId" runat="server" Value="0" />
        <asp:Literal ID="litResetInfo" runat="server"></asp:Literal>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtResetPassword" Font-Bold="True">New password *</asp:Label><br /><bbui:FormTextBox ID="txtResetPassword" runat="server" TextMode="Password" MaxLength="100"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <footer class="dialog-footer">
            <bbui:ActionButton
                ID="btnReset"
                runat="server"
                Text="Set Password"
                data-confirm="Set Password?"
                OnClick="btnReset_Click" />
            <bbui:ActionButton
                ID="btnCancelReset"
                runat="server"
                Text="Cancel"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancelReset_Click" />
        </footer>
    </bbui:Card>

    <!-- Search the account list by name or barangay. -->
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtAccountSearch">Search</asp:Label>
            <bbui:FormTextBox
                ID="txtAccountSearch"
                runat="server"
                MaxLength="100"
                placeholder="Name or username"
                AutoPostBack="true"
                CausesValidation="false"
                OnTextChanged="AccountFilterChanged"
                data-live="true" />
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlFilterBarangay">Barangay</asp:Label>
            <bbui:FormSelect
                ID="ddlFilterBarangay"
                runat="server"
                AutoPostBack="true"
                CausesValidation="false"
                OnSelectedIndexChanged="AccountFilterChanged" />
        </asp:Panel>
    </bbui:FieldRow>

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvUsers_RowCommand" EmptyDataText="No accounts yet.">
            <Columns>
                <asp:BoundField DataField="display_name" HeaderText="Name" />
                <asp:BoundField DataField="username" HeaderText="Username" />
                <asp:BoundField DataField="role" HeaderText="Role" />
                <asp:BoundField DataField="barangay_name" HeaderText="Barangay" />
                <asp:TemplateField HeaderText="Last Login">
                    <ItemTemplate><%# Ui.DateTimeText(Eval("last_login")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("account_status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span>
                            <asp:LinkButton runat="server" CommandName="ResetRow" CommandArgument='<%# Eval("user_id") %>' CausesValidation="false" Visible='<%# CInt(Eval("user_id")) <> Auth.UserId %>'>Reset Password</asp:LinkButton>
                            <asp:LinkButton runat="server" data-confirm="Change the status of this account?" CommandName="ToggleRow" CommandArgument='<%# Eval("user_id") %>'
                                Visible='<%# CInt(Eval("user_id")) <> Auth.UserId %>' CausesValidation="false" Text='<%# If(CStr(Eval("account_status")) = "Active", "Deactivate", "Activate") %>'></asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
