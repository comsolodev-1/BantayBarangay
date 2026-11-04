<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Barangay Report Monitoring</h1>
    <p>Public view of reporting activities, rankings and announcements for the 15 barangays of Talisay, Camarines Norte.</p>
    <asp:Table ID="litStats" runat="server" SkinID="Statistics">
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Barangays</asp:TableHeaderCell><asp:TableCell ID="statBarangays" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Public activities</asp:TableHeaderCell><asp:TableCell ID="statActivities" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Confirmed reports in <asp:Literal ID="statConfirmedYear" runat="server" /></asp:TableHeaderCell><asp:TableCell ID="statConfirmed" runat="server" HorizontalAlign="Right" /></asp:TableRow>
    </asp:Table>
    <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
        <h2>Top Ranking Barangays</h2>
        <asp:Panel runat="server" SkinID="GridArea">
            <asp:GridView ID="gvTop" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No ranking data yet.">
                <Columns>
                    <asp:BoundField DataField="Rank" HeaderText="Rank" />
                    <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
                    <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
                    <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
                </Columns>
            </asp:GridView>
        </asp:Panel>
        <asp:HyperLink runat="server" NavigateUrl="~/Viewer/Rankings.aspx">View full rankings</asp:HyperLink>
    </asp:TableCell></asp:TableRow></asp:Table>
    <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
        <h2>Reporting Activities</h2>
        <asp:Panel runat="server" SkinID="GridArea">
            <asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No public activities right now.">
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
        </asp:Panel>
    </asp:TableCell></asp:TableRow></asp:Table>
    <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
        <h2>Upcoming Important Dates</h2>
        <asp:Panel runat="server" SkinID="GridArea">
            <asp:GridView ID="gvDates" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No upcoming dates.">
                <Columns>
                    <asp:TemplateField HeaderText="Date">
                        <ItemTemplate><%# Ui.DateText(Eval("event_date")) %></ItemTemplate>
                    </asp:TemplateField>
                    <asp:BoundField DataField="title" HeaderText="Event" />
                    <asp:BoundField DataField="event_type" HeaderText="Type" />
                    <asp:BoundField DataField="location" HeaderText="Location" />
                </Columns>
            </asp:GridView>
        </asp:Panel>
    </asp:TableCell></asp:TableRow></asp:Table>
    <h2>Latest Announcements</h2>
    <bb:AnnouncementsView ID="annLatest" runat="server" MaxItems="3" />
</asp:Content>
