<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Dashboard.aspx.vb" Inherits="Barangay_Dashboard" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Dashboard</h1>
    <p class="sub">Overview of your barangay's report compliance.</p>
    <asp:Literal ID="litAlerts" runat="server"></asp:Literal>
    <asp:Literal ID="litStats" runat="server"></asp:Literal>
    <div class="card">
        <h2>Upcoming Deadlines</h2>
        <div class="grid-wrap">
            <asp:GridView ID="gvDeadlines" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="Nothing due. Great job!">
                <Columns>
                    <asp:BoundField DataField="activity_name" HeaderText="Activity" />
                    <asp:BoundField DataField="period_name" HeaderText="Period" />
                    <asp:TemplateField HeaderText="Deadline">
                        <ItemTemplate><%# Ui.DateText(Eval("submission_deadline")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate><%# Ui.Badge(Eval("display_status")) %></ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
        <a href="<%= ResolveUrl("~/Barangay/MyActivities.aspx") %>">Go to My Activities</a>
    </div>
    <h2>Latest Announcements</h2>
    <bb:AnnouncementsView ID="annLatest" runat="server" MaxItems="3" />
</asp:Content>
