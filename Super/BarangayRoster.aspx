<%@ Page
    Title="Barangay Roster"
    Language="VB"
    MasterPageFile="~/Site.master"
    AutoEventWireup="false"
    CodeFile="BarangayRoster.aspx.vb"
    Inherits="Super_BarangayRoster" %>
<%@ Register Src="~/Controls/RosterView.ascx" TagPrefix="bb" TagName="RosterView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Barangay Roster</h1>
    <p>View officials listed by each barangay.</p>

    <!-- Filter the shared roster. -->
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlBarangay">Barangay</asp:Label>
            <bbui:FormSelect
                ID="ddlBarangay"
                runat="server"
                AutoPostBack="true"
                CausesValidation="false"
                OnSelectedIndexChanged="FilterChanged" />
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch">Search</asp:Label>
            <bbui:FormTextBox
                ID="txtSearch"
                runat="server"
                MaxLength="100"
                placeholder="Name or position"
                CausesValidation="false" />
            <bbui:ActionButton runat="server" Text="Search" SkinID="Secondary" CausesValidation="false" OnClick="FilterChanged" />
        </asp:Panel>
    </bbui:FieldRow>

    <bb:RosterView ID="roster" runat="server" />
</asp:Content>
