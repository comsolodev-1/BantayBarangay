<%@ Page
    Title="Barangay Roster"
    Language="VB"
    MasterPageFile="~/Site.master"
    AutoEventWireup="false"
    CodeFile="BarangayRoster.aspx.vb"
    Inherits="Super_BarangayRoster" %>
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
                AutoPostBack="true"
                CausesValidation="false"
                OnTextChanged="FilterChanged"
                data-live="true" />
        </asp:Panel>
    </bbui:FieldRow>

    <bbui:Card runat="server" ContentPadding="0">
        <asp:GridView
            ID="gvRoster"
            runat="server"
            AutoGenerateColumns="false"
            GridLines="None"
            EmptyDataText="No roster members match this selection.">
            <Columns>
                <asp:BoundField DataField="barangay_name" HeaderText="Barangay" />
                <asp:BoundField DataField="full_name" HeaderText="Name" />
                <asp:BoundField DataField="position" HeaderText="Position" />
                <asp:BoundField DataField="committee" HeaderText="Committee" />
                <asp:BoundField DataField="status" HeaderText="Status" />
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
