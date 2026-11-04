<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Default.aspx.vb" Inherits="_Default" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Barangay Report Monitoring</asp:Label></p>
    <p>Public view of reporting activities, rankings and announcements for the 15 barangays of Talisay, Camarines Norte.</p>
    <bbui:FieldRow ID="litStats" runat="server" GapPixels="18">
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statBarangays" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Barangays</bbui:Card>
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statActivities" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Public activities</bbui:Card>
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statConfirmed" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Confirmed reports in <asp:Literal ID="statConfirmedYear" runat="server" /></bbui:Card>
    </bbui:FieldRow>
    <bbui:Card runat="server">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Top Ranking Barangays</asp:Label></p>
        <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
            <asp:GridView ID="gvTop" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No ranking data yet.">
                <Columns>
                    <asp:BoundField DataField="Rank" HeaderText="Rank" />
                    <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
                    <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
                    <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
                </Columns>
            </asp:GridView>
        </bbui:Card>
        <asp:HyperLink runat="server" NavigateUrl="~/Viewer/Rankings.aspx">View full rankings</asp:HyperLink>
    </bbui:Card>
    <bbui:Card runat="server">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Reporting Activities</asp:Label></p>
        <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
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
        </bbui:Card>
    </bbui:Card>
    <bbui:Card runat="server">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Upcoming Important Dates</asp:Label></p>
        <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
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
        </bbui:Card>
    </bbui:Card>
    <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Latest Announcements</asp:Label></p>
    <bb:AnnouncementsView ID="annLatest" runat="server" MaxItems="3" />
</asp:Content>
