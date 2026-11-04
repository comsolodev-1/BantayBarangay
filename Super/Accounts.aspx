<%@ Page Title="Accounts" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Accounts.aspx.vb" Inherits="Super_Accounts" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="panel-title">
        <div>
            <h1>Accounts</h1>
            <p class="sub">Create and manage Barangay Admin accounts. Each barangay has one admin account.</p>
        </div>
        <asp:Button ID="btnNew" runat="server" Text="+ New Account" CssClass="btn" CausesValidation="false" OnClick="btnNew_Click" />
    </div>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="card">
        <h2>Create Barangay Admin Account</h2>
        <div class="row">
            <div class="field">
                <label>Barangay *</label>
                <asp:DropDownList ID="ddlBarangay" runat="server"></asp:DropDownList>
            </div>
            <div class="field"><label>Username *</label><asp:TextBox ID="txtUsername" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Initial password *</label><asp:TextBox ID="txtPassword" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field"><label>First name *</label><asp:TextBox ID="txtFirst" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Middle name</label><asp:TextBox ID="txtMiddle" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Last name *</label><asp:TextBox ID="txtLast" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Suffix</label><asp:TextBox ID="txtSuffix" runat="server" MaxLength="10"></asp:TextBox></div>
            <div class="field"><label>Contact number</label><asp:TextBox ID="txtContact" runat="server" MaxLength="15"></asp:TextBox></div>
        </div>
        <asp:Button ID="btnSave" runat="server" Text="Create Account" CssClass="btn" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <asp:Panel ID="pnlReset" runat="server" Visible="false" CssClass="card">
        <h2>Reset Password</h2>
        <asp:HiddenField ID="hfResetUserId" runat="server" Value="0" />
        <asp:Literal ID="litResetInfo" runat="server"></asp:Literal>
        <div class="row">
            <div class="field"><label>New password *</label><asp:TextBox ID="txtResetPassword" runat="server" TextMode="Password" MaxLength="100"></asp:TextBox></div>
        </div>
        <asp:Button ID="btnReset" runat="server" Text="Set Password" CssClass="btn" OnClick="btnReset_Click" />
        <asp:Button ID="btnCancelReset" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancelReset_Click" />
    </asp:Panel>

    <div class="grid-wrap">
        <asp:GridView ID="gvUsers" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" OnRowCommand="gvUsers_RowCommand" EmptyDataText="No accounts yet.">
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
                        <span class="actions">
                            <asp:LinkButton runat="server" CommandName="ResetRow" CommandArgument='<%# Eval("user_id") %>' CausesValidation="false">Reset Password</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="ToggleRow" CommandArgument='<%# Eval("user_id") %>' CausesValidation="false" Text='<%# If(CStr(Eval("account_status")) = "Active", "Deactivate", "Activate") %>'></asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
