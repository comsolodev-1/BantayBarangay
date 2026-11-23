<%@ Page Title="Audit Logs" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="AuditLogs.aspx.vb" Inherits="Super_AuditLogs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Audit Logs</asp:Label></p>
    <bbui:Card runat="server" ContentPadding="16" role="search" aria-label="Audit log filters">
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="dateFrom" Font-Bold="True" Text="From" />
                <bbui:FormTextBox runat="server" ID="dateFrom" TextMode="Date" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="dateTo" Font-Bold="True" Text="To" />
                <bbui:FormTextBox runat="server" ID="dateTo" TextMode="Date" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="actionFilter" Font-Bold="True" Text="Action" />
                <bbui:FormSelect runat="server" ID="actionFilter" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="moduleFilter" Font-Bold="True" Text="Module" />
                <bbui:FormSelect runat="server" ID="moduleFilter" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="barangay" Font-Bold="True" Text="Barangay" />
                <bbui:FormSelect runat="server" ID="barangay" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server" ItemVerticalAlign="Bottom">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="searchText" Font-Bold="True" Text="Description contains" />
                <bbui:FormTextBox runat="server" ID="searchText" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="reportId" Font-Bold="True" Text="Report ID" />
                <bbui:FormTextBox runat="server" ID="reportId" />
            </asp:Panel>
            <bbui:ActionButton runat="server" Text="Search" SkinID="Toolbar" OnClick="Search_Click" />
        </bbui:FieldRow>
        <asp:HyperLink runat="server" NavigateUrl="~/Super/AuditLogs.aspx">Clear filters</asp:HyperLink>
        <asp:Literal ID="litFilterMessage" runat="server" EnableViewState="false" />
    </bbui:Card>

    <bbui:Card runat="server" ContentPadding="0" role="region" aria-label="Audit log entries">
        <bbui:DataGrid ID="eventsGrid" runat="server" MinimumWidth="864px" AutoGenerateColumns="false" GridLines="None" EmptyDataText="No log entries found.">
            <Columns>
                <asp:BoundField HeaderText="No." DataField="log_id" HeaderStyle-Width="5%" />
                <asp:BoundField HeaderText="Date &amp; time" DataField="occurred_at" DataFormatString="{0:MMM d, yyyy, h:mm tt}" HeaderStyle-Width="13%" />
                <asp:BoundField HeaderText="Action" DataField="action_name" HeaderStyle-Width="10%" />
                <asp:BoundField HeaderText="Module" DataField="ModuleName" HeaderStyle-Width="10%" />
                <asp:BoundField HeaderText="Barangay" DataField="Barangay" HeaderStyle-Width="10%" />
                <asp:BoundField HeaderText="Performed by" DataField="Performer" HeaderStyle-Width="16%" />
                <asp:BoundField HeaderText="Description" DataField="description" />
                <asp:BoundField HeaderText="Record ID" DataField="record_id" HeaderStyle-Width="7%" />
            </Columns>
        </bbui:DataGrid>
    </bbui:Card>
    <bbui:RecordPager ID="pager" runat="server" ShowSinglePageSummary="true" OnPageChanged="Pager_PageChanged" />
</asp:Content>
