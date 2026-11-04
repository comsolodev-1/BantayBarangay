<%@ Page Title="Officials and Roster" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Barangay_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Officials and Roster</asp:Label></p>
            <p>Barangay and Sangguniang Kabataan officials of your barangay.</p>
        </asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ Add Official" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlForm" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></asp:Label></p>
        <asp:HiddenField ID="hfRosterId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtFirst" Font-Bold="True">First name *</asp:Label><br /><bbui:FormTextBox ID="txtFirst" runat="server" MaxLength="50"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtMiddle" Font-Bold="True">Middle name</asp:Label><br /><bbui:FormTextBox ID="txtMiddle" runat="server" MaxLength="50"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtLast" Font-Bold="True">Last name *</asp:Label><br /><bbui:FormTextBox ID="txtLast" runat="server" MaxLength="50"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtSuffix" Font-Bold="True">Suffix</asp:Label><br /><bbui:FormTextBox ID="txtSuffix" runat="server" MaxLength="10"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtPosition" Font-Bold="True">Position *</asp:Label><br /><bbui:FormTextBox ID="txtPosition" runat="server" MaxLength="50"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtCommittee" Font-Bold="True">Committee</asp:Label><br /><bbui:FormTextBox ID="txtCommittee" runat="server" MaxLength="100"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContact" Font-Bold="True">Contact number</asp:Label><br /><bbui:FormTextBox ID="txtContact" runat="server" MaxLength="15"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtEmail" Font-Bold="True">Email</asp:Label><br /><bbui:FormTextBox ID="txtEmail" runat="server" MaxLength="100"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtAddress" Font-Bold="True">Address</asp:Label><br /><bbui:FormTextBox ID="txtAddress" runat="server" MaxLength="255"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
                <bbui:FormSelect ID="ddlStatus" runat="server">
                    <asp:ListItem>Active</asp:ListItem>
                    <asp:ListItem>Inactive</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:ActionButton ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
        <bbui:ActionButton ID="btnCancel" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancel_Click" />
    </bbui:Card>

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" GridLines="None" DataKeyNames="roster_id" OnRowCommand="gvRoster_RowCommand" EmptyDataText="No officials added yet.">
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
                        <span>
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this official?');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
