<%@ Page Title="Dashboard" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Dashboard.aspx.vb" Inherits="Super_Dashboard" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Dashboard</h1>
    <p class="sub">Municipal overview of barangay report compliance.</p>
    <asp:Literal ID="litAlerts" runat="server"></asp:Literal>
    <asp:Literal ID="litStats" runat="server"></asp:Literal>
    <div class="card">
        <h2>Submissions Waiting for Review</h2>
        <div class="grid-wrap">
            <asp:GridView ID="gvPending" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="No submissions waiting for review.">
                <Columns>
                    <asp:BoundField DataField="barangay_name" HeaderText="Barangay" />
                    <asp:BoundField DataField="activity_name" HeaderText="Activity" />
                    <asp:BoundField DataField="period_name" HeaderText="Period" />
                    <asp:TemplateField HeaderText="Submitted">
                        <ItemTemplate><%# Ui.DateTimeText(Eval("date_submitted")) %> <%# If(Convert.ToInt32(Eval("is_late")) = 1, Ui.Badge("Late"), "") %></ItemTemplate>
                    </asp:TemplateField>
                </Columns>
            </asp:GridView>
        </div>
        <a href="<%= ResolveUrl("~/Super/Submissions.aspx") %>">Review submissions</a>
    </div>
    <div class="card">
        <h2>Ranking This Year</h2>
        <div class="grid-wrap">
            <asp:GridView ID="gvRank" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None">
                <Columns>
                    <asp:BoundField DataField="Rank" HeaderText="Rank" />
                    <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
                    <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
                    <asp:BoundField DataField="Late" HeaderText="Late" />
                    <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
                </Columns>
            </asp:GridView>
        </div>
    </div>
</asp:Content>
