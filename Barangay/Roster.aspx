<%@ Page Title="Officials and Roster" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Barangay_Roster" %>
<%@ Register Src="~/Controls/RosterView.ascx" TagPrefix="bb" TagName="RosterView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server"><asp:Panel runat="server">
        <h1>Officials and Roster</h1><p>Barangay and Sangguniang Kabataan officials of your barangay.</p></asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ Add Official" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Workflow ID="pnlForm" runat="server" Visible="false">
        <bbui:DialogTitle runat="server"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></bbui:DialogTitle>
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
                <asp:Label runat="server" AssociatedControlID="ddlPosition">Position *</asp:Label>
                <bbui:RosterPositionSelect ID="ddlPosition" runat="server" aria-required="true" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtCommittee">Committee</asp:Label>
                <bbui:FormTextBox ID="txtCommittee" runat="server" MaxLength="100" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlStatus">Status</asp:Label>
                <bbui:FormSelect ID="ddlStatus" runat="server" AutoPostBack="true" CausesValidation="false">
                    <asp:ListItem>Active</asp:ListItem>
                    <asp:ListItem>Inactive</asp:ListItem>
                </bbui:FormSelect>
                <small>Only active officials count toward seat limits. Set the status before choosing a photo.</small>
            </asp:Panel>
        </bbui:FieldRow>
        <fieldset class="roster-term">
            <legend>Term of Service (Year Range)</legend>
            <bbui:FieldRow runat="server">
                <asp:Panel runat="server">
                    <asp:Label runat="server" AssociatedControlID="txtTermStart">Start year</asp:Label>
                    <bbui:FormTextBox ID="txtTermStart" runat="server" MaxLength="4" inputmode="numeric" placeholder="2016" />
                </asp:Panel>
                <asp:Panel runat="server">
                    <asp:Label runat="server" AssociatedControlID="txtTermEnd">End year</asp:Label>
                    <bbui:FormTextBox ID="txtTermEnd" runat="server" MaxLength="4" inputmode="numeric" placeholder="2029" />
                </asp:Panel>
            </bbui:FieldRow>
        </fieldset>
        <div class="popup-section">
            <asp:Label runat="server" AssociatedControlID="fuPhoto">Profile photo (JPG or PNG)</asp:Label>
            <div class="dropzone">
                <asp:FileUpload ID="fuPhoto" runat="server" accept="image/jpeg,image/png" />
            </div>
        </div>
        <bbui:DialogFooter runat="server">
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
        </bbui:DialogFooter>
    </bbui:Workflow>

    <bb:RosterView ID="roster" runat="server" AllowChanges="true" OnRowCommand="gvRoster_RowCommand" />
</asp:Content>
