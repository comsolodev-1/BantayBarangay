<%@ Page Title="Submissions" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Submissions.aspx.vb" Inherits="Super_Submissions" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Submissions</asp:Label></p>
    <p>Review reports submitted by the barangays. Confirm on-time reports for 1.0 point and late reports for 0.5 point, or deny with a reason.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlReview" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Review Submission</asp:Label></p>
        <asp:HiddenField ID="hfSubmissionId" runat="server" Value="0" />
        <asp:Literal ID="litReviewInfo" runat="server"></asp:Literal>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlRemark" Font-Bold="True">Remark (when confirming)</asp:Label><br />
                <asp:DropDownList ID="ddlRemark" runat="server">
                    <asp:ListItem>Good</asp:ListItem>
                    <asp:ListItem>Needs Improvement</asp:ListItem>
                    <asp:ListItem>Bad</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtDenyReason" Font-Bold="True">Reason for denial (required when denying)</asp:Label><br />
                <asp:TextBox ID="txtDenyReason" runat="server" MaxLength="255"></asp:TextBox>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="fuDenial" Font-Bold="True">Denial attachment (optional)</asp:Label><br />
                <asp:FileUpload ID="fuDenial" runat="server" />
            </asp:Panel>
        </bbui:FieldRow>
        <asp:Button ID="btnConfirm" runat="server" Text="Confirm" CausesValidation="false" OnClick="btnConfirm_Click" />
        <asp:Button ID="btnDeny" runat="server" Text="Deny" SkinID="Danger" CausesValidation="false" OnClick="btnDeny_Click" />
        <asp:Button ID="btnCancelReview" runat="server" Text="Close" SkinID="Secondary" CausesValidation="false" OnClick="btnCancelReview_Click" />
    </bbui:Card>

    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Value="Pending">Pending</asp:ListItem>
                <asp:ListItem Value="Confirmed">Confirmed</asp:ListItem>
                <asp:ListItem Value="Denied">Denied</asp:ListItem>
                <asp:ListItem Value="">All</asp:ListItem>
            </asp:DropDownList>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay</asp:Label><br />
            <asp:DropDownList ID="ddlBarangay" runat="server"></asp:DropDownList>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search activity</asp:Label><br />
            <asp:TextBox ID="txtSearch" runat="server" MaxLength="100"></asp:TextBox>
        </asp:Panel>
        <asp:Button ID="btnFilter" runat="server" Text="Filter" CausesValidation="false" OnClick="btnFilter_Click" />
    </bbui:FieldRow>

    <asp:Panel runat="server" SkinID="GridArea">
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
    </asp:Panel>
</asp:Content>
