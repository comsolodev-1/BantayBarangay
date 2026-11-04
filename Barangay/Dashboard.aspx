<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Dashboard.aspx.vb" Inherits="Barangay_Dashboard" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Dashboard</asp:Label></p>
    <p>Overview of your barangay's report compliance.</p>
    <asp:Literal ID="litAlerts" runat="server"></asp:Literal>
    <bbui:FieldRow ID="litStats" runat="server">
        <bbui:Card runat="server"><asp:Label ID="statNotSubmitted" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Not submitted</bbui:Card>
        <bbui:Card runat="server"><asp:Label ID="statPending" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Pending review</bbui:Card>
        <bbui:Card runat="server"><asp:Label ID="statConfirmed" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Confirmed</bbui:Card>
        <bbui:Card runat="server"><asp:Label ID="statDenied" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Denied</bbui:Card>
        <bbui:Card runat="server"><asp:Label ID="statScoreText" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Score <asp:Literal ID="statScoreTextYear" runat="server" /></bbui:Card>
        <bbui:Card runat="server"><asp:Label ID="statRankText" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Rank <asp:Literal ID="statRankTextYear" runat="server" /></bbui:Card>
    </bbui:FieldRow>
    <bbui:Card runat="server">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Upcoming Deadlines</asp:Label></p>
        <asp:Panel runat="server" SkinID="GridArea">
            <asp:GridView ID="gvDeadlines" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="Nothing due. Great job!">
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
        </asp:Panel>
        <asp:HyperLink runat="server" NavigateUrl="~/Barangay/MyActivities.aspx">Go to My Activities</asp:HyperLink>
    </bbui:Card>
    <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Latest Announcements</asp:Label></p>
    <bb:AnnouncementsView ID="annLatest" runat="server" MaxItems="3" />
</asp:Content>
