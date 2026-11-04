<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Dashboard.aspx.vb" Inherits="Super_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Dashboard</asp:Label></p>
    <p>Municipal overview of barangay report compliance.</p>
    <asp:Literal ID="litAlerts" runat="server"></asp:Literal>
    <bbui:FieldRow Columns="5" ID="litStats" runat="server" GapPixels="16">
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statActiveActivities" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Active activities</bbui:Card>
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statPending" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Pending review</bbui:Card>
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statConfirmed" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Confirmed in <asp:Literal ID="statConfirmedYear" runat="server" /></bbui:Card>
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statLate" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Late in <asp:Literal ID="statLateYear" runat="server" /></bbui:Card>
        <bbui:Card runat="server" SeparateAfter="false"><asp:Label ID="statMissing" runat="server" ForeColor="#1A5C38" Font-Size="20pt" Font-Bold="True" /><br />Overdue, not submitted</bbui:Card>
    </bbui:FieldRow>
    <bbui:Card runat="server">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Submissions Waiting for Review</asp:Label></p>
        <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
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
        </bbui:Card>
        <asp:HyperLink runat="server" NavigateUrl="~/Super/Submissions.aspx">Review submissions</asp:HyperLink>
    </bbui:Card>
    <bbui:Card runat="server">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Ranking This Year</asp:Label></p>
        <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
            <asp:GridView ID="gvRank" runat="server" AutoGenerateColumns="False" GridLines="None">
                <Columns>
                    <asp:BoundField DataField="Rank" HeaderText="Rank" />
                    <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
                    <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
                    <asp:BoundField DataField="Late" HeaderText="Late" />
                    <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
                </Columns>
            </asp:GridView>
        </bbui:Card>
    </bbui:Card>
</asp:Content>
