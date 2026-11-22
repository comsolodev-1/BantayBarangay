<%@ Page Title="My Reports" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="MyReports.aspx.vb" Inherits="Barangay_MyReports" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">My Reports</asp:Label></p>
    <p>History of your barangay's report submissions.</p>
    <bbui:FieldRow runat="server" CssClass="history-tools" ItemVerticalAlign="Bottom">
        <asp:Panel runat="server" CssClass="history-year">
            <asp:Label runat="server" AssociatedControlID="ddlYear" Font-Bold="True">Year</asp:Label><br />
            <bbui:FormSelect ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlYear_SelectedIndexChanged"></bbui:FormSelect>
        </asp:Panel>
        <div style="display:flex;gap:8px;flex-wrap:wrap">
            <bbui:ActionButton ID="btnPrintHistory" runat="server" Text="Print submission history" SkinID="ToolbarSecondary"
                CausesValidation="false" formtarget="_blank" OnClick="btnPrintHistory_Click" />
            <bbui:ActionButton ID="btnReportCard" runat="server" Text="Download Report Card (PDF)" SkinID="Toolbar" CausesValidation="false" OnClick="btnReportCard_Click" />
        </div>
    </bbui:FieldRow>
    <bbui:Card runat="server" CssClass="report-document submission-history" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <bbui:DataGrid ShowHeaderWhenEmpty="True" ID="gvHistory" runat="server" MinimumWidth="640px" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No submissions for this year.">
            <Columns>
                <asp:BoundField DataField="activity_name" HeaderText="Activity" />
                <asp:BoundField DataField="period_name" HeaderText="Period" />
                <asp:TemplateField HeaderText="Submitted">
                    <ItemTemplate><%# Ui.DateTimeText(Eval("date_submitted")) %> <%# If(Convert.ToInt32(Eval("is_late")) = 1, Ui.Badge("Late"), "") %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="File">
                    <ItemTemplate><a href="<%# ResolveUrl("~/Download.aspx") %>?t=submission&amp;id=<%# Eval("date_id") %>"><%# Ui.H(Eval("file_name")) %></a></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("submission_status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Score">
                    <ItemTemplate><%# Ui.ScoreText(Eval("score")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Remarks / Reason">
                    <ItemTemplate><%# Ui.H(Eval("remarks")) %> <%# Ui.H(Eval("denial_reason")) %></ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </bbui:DataGrid>
    </bbui:Card>
</asp:Content>
