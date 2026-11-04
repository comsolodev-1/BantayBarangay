<%@ Page Title="Accounts" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Accounts.aspx.vb" Inherits="Super_Accounts" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Accounts</asp:Label></p>
            <p>Create and manage Barangay Admin accounts. Each barangay has one admin account.</p>
        </asp:Panel>
        <asp:Button ID="btnNew" runat="server" Text="+ New Account" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlForm" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Create Barangay Admin Account</asp:Label></p>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay *</asp:Label><br />
                <asp:DropDownList ID="ddlBarangay" runat="server"></asp:DropDownList>
            </asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtUsername" Font-Bold="True">Username *</asp:Label><br /><asp:TextBox ID="txtUsername" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtPassword" Font-Bold="True">Initial password *</asp:Label><br /><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtFirst" Font-Bold="True">First name *</asp:Label><br /><asp:TextBox ID="txtFirst" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtMiddle" Font-Bold="True">Middle name</asp:Label><br /><asp:TextBox ID="txtMiddle" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtLast" Font-Bold="True">Last name *</asp:Label><br /><asp:TextBox ID="txtLast" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtSuffix" Font-Bold="True">Suffix</asp:Label><br /><asp:TextBox ID="txtSuffix" runat="server" MaxLength="10"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContact" Font-Bold="True">Contact number</asp:Label><br /><asp:TextBox ID="txtContact" runat="server" MaxLength="15"></asp:TextBox></asp:Panel>
        </bbui:FieldRow>
        <asp:Button ID="btnSave" runat="server" Text="Create Account" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancel_Click" />
    </bbui:Card>

    <bbui:Card ID="pnlReset" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Reset Password</asp:Label></p>
        <asp:HiddenField ID="hfResetUserId" runat="server" Value="0" />
        <asp:Literal ID="litResetInfo" runat="server"></asp:Literal>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtResetPassword" Font-Bold="True">New password *</asp:Label><br /><asp:TextBox ID="txtResetPassword" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox></asp:Panel>
        </bbui:FieldRow>
        <asp:Button ID="btnReset" runat="server" Text="Set Password" OnClick="btnReset_Click" />
        <asp:Button ID="btnCancelReset" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancelReset_Click" />
    </bbui:Card>

    <asp:Panel runat="server" SkinID="GridArea">
        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvUsers_RowCommand" EmptyDataText="No accounts yet.">
            <Columns>
                <asp:BoundField DataField="username" HeaderText="Username" />
                <asp:BoundField DataField="full_name" HeaderText="Name" />
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
                            <asp:LinkButton runat="server" CommandName="ResetRow" CommandArgument='<%# Eval("user_id") %>' CausesValidation="false">Reset Password</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ToggleRow" CommandArgument='<%# Eval("user_id") %>' CausesValidation="false" Text='<%# If(CStr(Eval("account_status")) = "Active", "Deactivate", "Activate") %>'></asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </asp:Panel>
</asp:Content>
