<%@ Page Title="My Reports" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="MyReports.aspx.vb" Inherits="Barangay_MyReports" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>My Reports</h1>
    <p class="sub">History of your barangay's report submissions.</p>
    <div class="row">
        <div class="field">
            <label>Year</label>
            <asp:DropDownList ID="ddlYear" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlYear_SelectedIndexChanged"></asp:DropDownList>
        </div>
        <asp:Button ID="btnReportCard" runat="server" Text="Download Report Card (PDF)" CssClass="btn" CausesValidation="false" OnClick="btnReportCard_Click" />
    </div>
    <div class="grid-wrap">
        <asp:GridView ID="gvHistory" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="No submissions for this year.">
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
        </asp:GridView>
    </div>
</asp:Content>
