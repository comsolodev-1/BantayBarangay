<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Dashboard.aspx.vb" Inherits="Super_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Dashboard</h1>
    <p>Municipal overview of barangay report compliance.</p>
    <asp:Literal ID="litAlerts" runat="server"></asp:Literal>
    <asp:Table ID="litStats" runat="server" SkinID="Statistics">
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Active activities</asp:TableHeaderCell><asp:TableCell ID="statActiveActivities" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Pending review</asp:TableHeaderCell><asp:TableCell ID="statPending" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Confirmed in <asp:Literal ID="statConfirmedYear" runat="server" /></asp:TableHeaderCell><asp:TableCell ID="statConfirmed" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Late in <asp:Literal ID="statLateYear" runat="server" /></asp:TableHeaderCell><asp:TableCell ID="statLate" runat="server" HorizontalAlign="Right" /></asp:TableRow>
        <asp:TableRow><asp:TableHeaderCell Scope="Row" HorizontalAlign="Left">Overdue, not submitted</asp:TableHeaderCell><asp:TableCell ID="statMissing" runat="server" HorizontalAlign="Right" /></asp:TableRow>
    </asp:Table>
    <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
        <h2>Submissions Waiting for Review</h2>
        <asp:Panel runat="server" SkinID="GridArea">
            <asp:GridView ID="gvPending" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No submissions waiting for review.">
                <Columns>
                    <asp:BoundField DataField="barangay_name" HeaderText="Barangay" />
                    <asp:BoundField DataField="activity_name" HeaderText="Activity" />
                    <asp:BoundField DataField="period_name" HeaderText="Period" />
                    <asp:TemplateField HeaderText="Submitted">
                        <ItemTemplate><%# Ui.DateTimeText(Eval("date_submitted")) %> <%# If(Convert.ToInt32(Eval("is_late")) = 1, Ui.Badge("Late"), "") %></ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </asp:Panel>
        <asp:HyperLink runat="server" NavigateUrl="~/Super/Submissions.aspx">Review submissions</asp:HyperLink>
    </asp:TableCell></asp:TableRow></asp:Table>
    <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
        <h2>Ranking This Year</h2>
        <asp:Panel runat="server" SkinID="GridArea">
            <asp:GridView ID="gvRank" runat="server" AutoGenerateColumns="False" GridLines="None">
                <Columns>
                    <asp:BoundField DataField="Rank" HeaderText="Rank" />
                    <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
                    <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
                    <asp:BoundField DataField="Late" HeaderText="Late" />
                    <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
                </Columns>
            </asp:GridView>
        </asp:Panel>
    </asp:TableCell></asp:TableRow></asp:Table>
</asp:Content>
