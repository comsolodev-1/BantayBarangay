<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Barangay Report Monitoring</h1>
    <p class="sub">Public view of reporting activities, rankings and announcements for the 15 barangays of Talisay, Camarines Norte.</p>
    <asp:Literal ID="litStats" runat="server"></asp:Literal>
    <div class="card">
        <h2>Top Ranking Barangays</h2>
        <div class="grid-wrap">
            <asp:GridView ID="gvTop" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="No ranking data yet.">
                <Columns>
                    <asp:BoundField DataField="Rank" HeaderText="Rank" />
                    <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
                    <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
                    <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
                </Columns>
            </asp:GridView>
        </div>
        <a href="<%= ResolveUrl("~/Viewer/Rankings.aspx") %>">View full rankings</a>
    </div>
    <div class="card">
        <h2>Reporting Activities</h2>
        <div class="grid-wrap">
            <asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="No public activities right now.">
                <Columns>
                    <asp:BoundField DataField="activity_name" HeaderText="Activity" />
                    <asp:BoundField DataField="frequency" HeaderText="Frequency" />
                    <asp:BoundField DataField="period_name" HeaderText="Period" />
                    <asp:TemplateField HeaderText="Deadline">
                        <ItemTemplate><%# Ui.DateText(Eval("submission_deadline")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:TemplateField HeaderText="Status">
                        <ItemTemplate><%# Ui.Badge(Eval("period_status")) %></ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
    </div>
    <div class="card">
        <h2>Upcoming Important Dates</h2>
        <div class="grid-wrap">
            <asp:GridView ID="gvDates" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="No upcoming dates.">
                <Columns>
                    <asp:TemplateField HeaderText="Date">
                        <ItemTemplate><%# Ui.DateText(Eval("event_date")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="title" HeaderText="Event" />
                    <asp:BoundField DataField="event_type" HeaderText="Type" />
                    <asp:BoundField DataField="location" HeaderText="Location" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
    <h2>Latest Announcements</h2>
    <bb:AnnouncementsView ID="annLatest" runat="server" MaxItems="3" />
</asp:Content>
