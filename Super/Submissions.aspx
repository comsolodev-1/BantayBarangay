<%@ Page Title="Submissions" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Submissions.aspx.vb" Inherits="Super_Submissions" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Submissions</h1>
    <p class="sub">Review reports submitted by the barangays. Confirm on-time reports for 1.0 point and late reports for 0.5 point, or deny with a reason.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlReview" runat="server" Visible="false" CssClass="card">
        <h2>Review Submission</h2>
        <asp:HiddenField ID="hfSubmissionId" runat="server" Value="0" />
        <asp:Literal ID="litReviewInfo" runat="server"></asp:Literal>
        <div class="row">
            <div class="field">
                <label>Remark (when confirming)</label>
                <asp:DropDownList ID="ddlRemark" runat="server">
                    <asp:ListItem>Good</asp:ListItem>
                    <asp:ListItem>Needs Improvement</asp:ListItem>
                    <asp:ListItem>Bad</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="field wide">
                <label>Reason for denial (required when denying)</label>
                <asp:TextBox ID="txtDenyReason" runat="server" MaxLength="255"></asp:TextBox>
            </div>
        </div>
        <div class="row">
            <div class="field wide">
                <label>Denial attachment (optional)</label>
                <asp:FileUpload ID="fuDenial" runat="server" />
            </div>
        </div>
        <asp:Button ID="btnConfirm" runat="server" Text="Confirm" CssClass="btn" CausesValidation="false" OnClick="btnConfirm_Click" />
        <asp:Button ID="btnDeny" runat="server" Text="Deny" CssClass="btn btn-danger" CausesValidation="false" OnClick="btnDeny_Click" />
        <asp:Button ID="btnCancelReview" runat="server" Text="Close" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancelReview_Click" />
    </asp:Panel>

    <div class="row">
        <div class="field">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                <asp:ListItem Value="Confirmed">Confirmed</asp:ListItem>
                <asp:ListItem Value="Denied">Denied</asp:ListItem>
                <asp:ListItem Value="">All</asp:ListItem>
            </asp:DropDownList>
        </div>
        <div class="field">
            <label>Barangay</label>
            <asp:DropDownList ID="ddlBarangay" runat="server"></asp:DropDownList>
        </div>
        <div class="field wide">
            <label>Search activity</label>
            <asp:TextBox ID="txtSearch" runat="server" MaxLength="100"></asp:TextBox>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn" CausesValidation="false" OnClick="btnFilter_Click" />
    </div>

    <div class="grid-wrap">
        <asp:GridView ID="gvSubmissions" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" OnRowCommand="gvSubmissions_RowCommand" EmptyDataText="No submissions found.">
            <Columns>
                <asp:BoundField DataField="barangay_name" HeaderText="Barangay" />
                <asp:BoundField DataField="activity_name" HeaderText="Activity" />
                <asp:BoundField DataField="period_name" HeaderText="Period" />
                <asp:TemplateField HeaderText="Submitted">
                    <ItemTemplate><%# Ui.DateTimeText(Eval("date_submitted")) %> <%# If(Convert.ToInt32(Eval("is_late")) = 1, Ui.Badge("Late"), "") %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="File">
                    <ItemTemplate><a href="<%# ResolveUrl("~/Download.aspx") %>?t=submission&amp;id=<%# Eval("date_id") %>"><%# Ui.H(Eval("file_name")) %></a></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("submission_status")) %> <%# If(CStr(Eval("submission_status")) = "Confirmed", "<small>" & Ui.ScoreText(Eval("score")) & " pt</small>", "") %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Remarks / Reason">
                    <ItemTemplate><%# Ui.H(Eval("remarks")) %> <%# Ui.H(Eval("denial_reason")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <span class="actions">
                            <asp:LinkButton runat="server" CommandName="ReviewRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false" Visible='<%# CStr(Eval("submission_status")) = "Pending" %>'>Review</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
