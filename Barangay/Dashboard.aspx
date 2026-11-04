<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Dashboard.aspx.vb" Inherits="Barangay_Dashboard" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Dashboard</h1>
    <p>Overview of your barangay's report compliance.</p>
    <asp:Literal ID="litAlerts" runat="server"></asp:Literal>
    <asp:Table ID="litStats" runat="server" SkinID="Statistics">
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Not submitted</asp:TableHeaderCell><asp:TableCell ID="statNotSubmitted" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Pending review</asp:TableHeaderCell><asp:TableCell ID="statPending" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Confirmed</asp:TableHeaderCell><asp:TableCell ID="statConfirmed" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Denied</asp:TableHeaderCell><asp:TableCell ID="statDenied" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Score <asp:Literal ID="statScoreTextYear" runat="server" /></asp:TableHeaderCell><asp:TableCell ID="statScoreText" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Rank <asp:Literal ID="statRankTextYear" runat="server" /></asp:TableHeaderCell><asp:TableCell ID="statRankText" runat="server" HorizontalAlign="Right" /></asp:TableRow>
    </asp:Table>
    <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
        <h2>Upcoming Deadlines</h2>
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
    </asp:TableCell></asp:TableRow></asp:Table>
    <h2>Latest Announcements</h2>
    <bb:AnnouncementsView ID="annLatest" runat="server" MaxItems="3" />
</asp:Content>
