<%@ Page Title="Officials and Roster" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Barangay_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel runat="server">
        <asp:Panel runat="server">
            <h1>Officials and Roster</h1>
            <p>Barangay and Sangguniang Kabataan officials of your barangay.</p>
        </asp:Panel>
        <asp:Button ID="btnNew" runat="server" Text="+ Add Official" CausesValidation="false" OnClick="btnNew_Click" />
    </asp:Panel>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" BorderWidth="1px" BorderColor="#A8D5B5" BorderStyle="Solid" BackColor="White">
        <h2><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></h2>
        <asp:HiddenField ID="hfRosterId" runat="server" Value="0" />
        <asp:Panel runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtFirst" Font-Bold="True">First name *</asp:Label><br /><asp:TextBox ID="txtFirst" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtMiddle" Font-Bold="True">Middle name</asp:Label><br /><asp:TextBox ID="txtMiddle" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtLast" Font-Bold="True">Last name *</asp:Label><br /><asp:TextBox ID="txtLast" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtSuffix" Font-Bold="True">Suffix</asp:Label><br /><asp:TextBox ID="txtSuffix" runat="server" MaxLength="10"></asp:TextBox></asp:Panel>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtPosition" Font-Bold="True">Position *</asp:Label><br /><asp:TextBox ID="txtPosition" runat="server" MaxLength="50"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtCommittee" Font-Bold="True">Committee</asp:Label><br /><asp:TextBox ID="txtCommittee" runat="server" MaxLength="100"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContact" Font-Bold="True">Contact number</asp:Label><br /><asp:TextBox ID="txtContact" runat="server" MaxLength="15"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtEmail" Font-Bold="True">Email</asp:Label><br /><asp:TextBox ID="txtEmail" runat="server" MaxLength="100"></asp:TextBox></asp:Panel>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtAddress" Font-Bold="True">Address</asp:Label><br /><asp:TextBox ID="txtAddress" runat="server" MaxLength="255"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
                <asp:DropDownList ID="ddlStatus" runat="server">
                    <asp:ListItem>Active</asp:ListItem>
                    <asp:ListItem>Inactive</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
        </asp:Panel>
        <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <asp:Panel runat="server" SkinID="GridArea">
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
    </asp:Panel>
</asp:Content>
