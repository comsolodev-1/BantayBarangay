<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RankingsView.ascx.vb" Inherits="RankingsView" %>
<bbui:FieldRow runat="server">
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="ddlYear" Font-Bold="True">Year</asp:Label><br />
        <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
    </asp:Panel>
    <asp:Panel runat="server">
        <asp:Label runat="server" AssociatedControlID="ddlMonth" Font-Bold="True">Month</asp:Label><br />
        <asp:DropDownList ID="ddlMonth" runat="server" AutoPostBack="true" OnSelectedIndexChanged="Filter_Changed"></asp:DropDownList>
    </asp:Panel>
</bbui:FieldRow>
<p>Ranking is based on the accumulated compliance scores of confirmed reports (on time = 1.0, late = 0.5).</p>
<asp:Panel runat="server" SkinID="GridArea">
    <asp:GridView ID="gvRank" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowDataBound="gvRank_RowDataBound" EmptyDataText="No ranking data yet.">
        <Columns>
            <asp:BoundField DataField="Rank" HeaderText="Rank" />
            <asp:BoundField DataField="Barangay" HeaderText="Barangay" />
            <asp:BoundField DataField="Confirmed" HeaderText="Confirmed Reports" />
            <asp:BoundField DataField="Late" HeaderText="Late" />
            <asp:BoundField DataField="Score" HeaderText="Total Score" DataFormatString="{0:0.0#}" />
        </Columns>
    </asp:GridView>
</asp:Panel>
