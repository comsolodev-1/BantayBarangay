<%@ Page Title="Officials and Roster" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Barangay_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="panel-title">
        <div>
            <h1>Officials and Roster</h1>
            <p class="sub">Barangay and Sangguniang Kabataan officials of your barangay.</p>
        </div>
        <asp:Button ID="btnNew" runat="server" Text="+ Add Official" CssClass="btn" CausesValidation="false" OnClick="btnNew_Click" />
    </div>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="card">
        <h2><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></h2>
        <asp:HiddenField ID="hfRosterId" runat="server" Value="0" />
        <div class="row">
            <div class="field"><label>First name *</label><asp:TextBox ID="txtFirst" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Middle name</label><asp:TextBox ID="txtMiddle" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Last name *</label><asp:TextBox ID="txtLast" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Suffix</label><asp:TextBox ID="txtSuffix" runat="server" MaxLength="10"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field"><label>Position *</label><asp:TextBox ID="txtPosition" runat="server" MaxLength="50"></asp:TextBox></div>
            <div class="field"><label>Committee</label><asp:TextBox ID="txtCommittee" runat="server" MaxLength="100"></asp:TextBox></div>
            <div class="field"><label>Contact number</label><asp:TextBox ID="txtContact" runat="server" MaxLength="15"></asp:TextBox></div>
            <div class="field"><label>Email</label><asp:TextBox ID="txtEmail" runat="server" MaxLength="100"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field wide"><label>Address</label><asp:TextBox ID="txtAddress" runat="server" MaxLength="255"></asp:TextBox></div>
            <div class="field">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server">
                    <asp:ListItem>Active</asp:ListItem>
                    <asp:ListItem>Inactive</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <div class="grid-wrap">
        <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" DataKeyNames="roster_id" OnRowCommand="gvRoster_RowCommand" EmptyDataText="No officials added yet.">
            <Columns>
                <asp:BoundField DataField="full_name" HeaderText="Name" />
                <asp:BoundField DataField="position" HeaderText="Position" />
                <asp:BoundField DataField="committee" HeaderText="Committee" />
                <asp:BoundField DataField="contact_number" HeaderText="Contact" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span class="actions">
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="danger" CommandName="DeleteRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this official?');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
