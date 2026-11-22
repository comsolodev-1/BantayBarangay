<%@ Page Title="Officials and Roster" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Barangay_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server"><asp:Panel runat="server">
        <h1>Officials and Roster</h1><p>Barangay and Sangguniang Kabataan officials of your barangay.</p></asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ Add Official" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlForm" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></asp:Label></p>
        <asp:HiddenField ID="hfRosterId" runat="server" Value="0" />
        <!-- Official's name and contact information. -->
        <bbui:FieldRow runat="server" CssClass="roster-name-fields">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtFirst">First name *</asp:Label>
                <bbui:FormTextBox ID="txtFirst" runat="server" MaxLength="50" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtMiddle">Middle name</asp:Label>
                <bbui:FormTextBox ID="txtMiddle" runat="server" MaxLength="50" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtLast">Last name *</asp:Label>
                <bbui:FormTextBox ID="txtLast" runat="server" MaxLength="50" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtSuffix">Suffix</asp:Label>
                <bbui:FormTextBox ID="txtSuffix" runat="server" MaxLength="10" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtEmail">Email</asp:Label>
                <bbui:FormTextBox ID="txtEmail" runat="server" MaxLength="100" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtContact">Contact number</asp:Label>
                <bbui:FormTextBox ID="txtContact" runat="server" MaxLength="15" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtAddress">Address</asp:Label>
                <bbui:FormTextBox ID="txtAddress" runat="server" MaxLength="255" />
            </asp:Panel>
        </bbui:FieldRow>
        <!-- Appointment and photo. -->
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtPosition">Position *</asp:Label>
                <bbui:FormTextBox ID="txtPosition" runat="server" MaxLength="50" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtCommittee">Committee</asp:Label>
                <bbui:FormTextBox ID="txtCommittee" runat="server" MaxLength="100" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlStatus">Status</asp:Label>
                <bbui:FormSelect ID="ddlStatus" runat="server">
                    <asp:ListItem>Active</asp:ListItem>
                    <asp:ListItem>Inactive</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
        </bbui:FieldRow>
        <div class="popup-section">
            <asp:Label runat="server" AssociatedControlID="fuPhoto">Profile photo (JPG or PNG)</asp:Label>
            <div class="dropzone">
                <asp:FileUpload ID="fuPhoto" runat="server" accept="image/jpeg,image/png" />
                <span>Choose a photo or drag it here</span>
            </div>
        </div>
        <footer class="dialog-footer">
            <bbui:ActionButton
                ID="btnSave"
                runat="server"
                Text="Save"
                data-confirm="Save?"
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

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" GridLines="None" DataKeyNames="roster_id" OnRowCommand="gvRoster_RowCommand" EmptyDataText="No officials added yet.">
            <Columns>
                <asp:TemplateField HeaderText="Photo"><ItemTemplate>
                    <asp:Image runat="server" CssClass="portrait" AlternateText="Official portrait" Visible='<%# Not IsDBNull(Eval("photo_path")) %>' ImageUrl='<%# "~/Download.aspx?t=portrait&id=" & Eval("roster_id").ToString() %>' />
                </ItemTemplate></asp:TemplateField>
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
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false" data-confirm="Delete this official?">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
