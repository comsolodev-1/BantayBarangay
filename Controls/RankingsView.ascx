<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RankingsView.ascx.vb" Inherits="RankingsView" %>
<div class="row">
    <div class="field">
        <label>Year</label>
        <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
    </div>
    <div class="field">
        <label>Month</label>
        <asp:DropDownList ID="ddlMonth" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
    </div>
</div>
<p class="sub">Ranking is based on the accumulated compliance scores of confirmed reports (on time = 1.0, late = 0.5).</p>
<div class="grid-wrap">
    <asp:GridView ID="gvRank" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" OnRowDataBound="gvRank_RowDataBound" EmptyDataText="No ranking data yet.">
        <Columns>
            <asp:BoundField DataField="Rank" HeaderText="Rank" />
            <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
            <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
            <asp:BoundField DataField="Late" HeaderText="Late" />
            <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
        </Columns>
    </asp:GridView>
</div>
