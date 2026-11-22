<%@ Page Title="Audit Logs" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="AuditLogs.aspx.vb" Inherits="Super_AuditLogs" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Audit Logs</h1>
    <div class="audit-filters">
        <div><asp:Label runat="server" AssociatedControlID="dateFrom" Text="From" /><asp:TextBox runat="server" ID="dateFrom" TextMode="Date" /></div>
        <div><asp:Label runat="server" AssociatedControlID="dateTo" Text="To" /><asp:TextBox runat="server" ID="dateTo" TextMode="Date" /></div>
        <div><asp:Label runat="server" AssociatedControlID="actionFilter" Text="Action" /><asp:DropDownList runat="server" ID="actionFilter" /></div>
        <div><asp:Label runat="server" AssociatedControlID="moduleFilter" Text="Module" /><asp:DropDownList runat="server" ID="moduleFilter" /></div>
        <div><asp:Label runat="server" AssociatedControlID="barangay" Text="Barangay" /><asp:DropDownList runat="server" ID="barangay" /></div>
        <div><asp:Label runat="server" AssociatedControlID="searchText" Text="Description contains" /><asp:TextBox runat="server" ID="searchText" TextMode="SingleLine" /></div>
        <div><asp:Label runat="server" AssociatedControlID="reportId" Text="Report ID" /><asp:TextBox runat="server" ID="reportId" TextMode="SingleLine" /></div>
    </div>
    <asp:Button runat="server" Text="Search" OnClick="Search_Click" /> <asp:HyperLink runat="server" NavigateUrl="~/Super/AuditLogs.aspx">Clear filters</asp:HyperLink>
    <div class="audit-scroll" tabindex="0" role="region" aria-label="Audit log entries"><asp:GridView ID="eventsGrid" runat="server" AutoGenerateColumns="false" GridLines="None" EmptyDataText="No log entries found."><Columns>
        <asp:BoundField HeaderText="No." DataField="log_id"  />
        <asp:BoundField HeaderText="Date &amp; time" DataField="occurred_at" DataFormatString="{0:MMM d, yyyy, h:mm tt}" />
        <asp:TemplateField HeaderText="Action"><ItemTemplate><span class="audit-action"><%#: Eval("action_name") %></span></ItemTemplate></asp:TemplateField>
        <asp:BoundField HeaderText="Module" DataField="ModuleName"  />
        <asp:BoundField HeaderText="Barangay" DataField="Barangay"  />
        <asp:BoundField HeaderText="Performed by" DataField="Performer"  />
        <asp:BoundField HeaderText="Description" DataField="description"  />
        <asp:BoundField HeaderText="Record ID" DataField="record_id"  />
    </Columns></asp:GridView></div>
    <footer class="audit-pager"><asp:Button ID="previous" runat="server" Text="Previous" OnClick="Page_Click" /><asp:Label ID="message" runat="server" role="status" /><asp:Button ID="older" runat="server" Text="Next" OnClick="Page_Click" /></footer>
</asp:Content>
