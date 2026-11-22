<%@ Page Title="Submissions" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Submissions.aspx.vb" Inherits="Super_Submissions" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Submissions</asp:Label></p>
    <p>Review reports submitted by the barangays. Confirm on-time reports for 1.0 point and late reports for 0.5 point, or deny with a reason.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlReview" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Review Submission</asp:Label></p>
        <asp:HiddenField ID="hfSubmissionId" runat="server" Value="0" />
        <asp:Literal ID="litReviewInfo" runat="server"></asp:Literal>
        <bbui:FieldRow runat="server" CssClass="review-fields">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlRemark">Remark</asp:Label>
                <bbui:FormSelect ID="ddlRemark" runat="server">
                    <asp:ListItem>Good</asp:ListItem>
                    <asp:ListItem>Needs Improvement</asp:ListItem>
                    <asp:ListItem>Bad</asp:ListItem>
                </bbui:FormSelect>
                <small>Recorded when you confirm the report.</small>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtReason">Reason</asp:Label>
                <bbui:FormTextBox ID="txtReason" runat="server" MaxLength="255"></bbui:FormTextBox>
                <small>Visible to the barangay. Required when denying a report.</small>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="fuDenial" Font-Bold="True">Denial attachment (optional)</asp:Label><br />
                <div class="dropzone">
                    <asp:FileUpload ID="fuDenial" runat="server" />
                    <span>Choose a file or drag it here</span>
                </div>
            </asp:Panel>
        </bbui:FieldRow>
        <footer class="dialog-footer">
            <bbui:ActionButton
                ID="btnConfirm"
                runat="server"
                Text="Confirm"
                data-confirm="Confirm this report?"
                data-description="The barangay will see the selected remark, the score, and any reason you enter."
                CausesValidation="false"
                OnClick="btnConfirm_Click" />
            <bbui:ActionButton
                ID="btnDeny"
                runat="server"
                Text="Deny"
                data-confirm="Deny this report?"
                data-description="The barangay will see your reason and can submit a corrected report."
                SkinID="Danger"
                CausesValidation="false"
                OnClick="btnDeny_Click" />
            <bbui:ActionButton
                ID="btnCancelReview"
                runat="server"
                Text="Close"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancelReview_Click" />
        </footer>
    </bbui:Card>

    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
            <bbui:FormSelect ID="ddlStatus" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="btnFilter_Click">
                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                <asp:ListItem Value="Confirmed">Confirmed</asp:ListItem>
                <asp:ListItem Value="Denied">Denied</asp:ListItem>
                <asp:ListItem Value="">All</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay</asp:Label><br />
            <bbui:FormSelect ID="ddlBarangay" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="btnFilter_Click"></bbui:FormSelect>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search activity</asp:Label><br />
            <bbui:FormTextBox ID="txtSearch" runat="server" MaxLength="100" AutoPostBack="true" CausesValidation="false" OnTextChanged="btnFilter_Click" data-live="true"></bbui:FormTextBox>
        </asp:Panel>
    </bbui:FieldRow>

    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSubmittedFrom">Submitted from</asp:Label>
            <bbui:FormTextBox ID="txtSubmittedFrom" runat="server" TextMode="Date" AutoPostBack="true" CausesValidation="false" OnTextChanged="btnFilter_Click" />
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSubmittedTo">Submitted through</asp:Label>
            <bbui:FormTextBox ID="txtSubmittedTo" runat="server" TextMode="Date" AutoPostBack="true" CausesValidation="false" OnTextChanged="btnFilter_Click" />
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlDateOrder">Submission date order</asp:Label>
            <bbui:FormSelect ID="ddlDateOrder" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="btnFilter_Click">
                <asp:ListItem Value="desc">Newest first</asp:ListItem>
                <asp:ListItem Value="asc">Oldest first</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
    </bbui:FieldRow>
    <asp:Literal ID="litDateMessage" runat="server" />
    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvSubmissions" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvSubmissions_RowCommand" EmptyDataText="No submissions found.">
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
                        <span>
                            <asp:LinkButton runat="server" CommandName="ReviewRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false" Visible='<%# CStr(Eval("submission_status")) = "Pending" %>'>Review</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
