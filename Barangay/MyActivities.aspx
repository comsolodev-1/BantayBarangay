<%@ Page Title="My Activities" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="MyActivities.aspx.vb" Inherits="Barangay_MyActivities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">My Activities</asp:Label></p>
    <p>Reporting activities assigned to your barangay.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlSubmit" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Submit Report</asp:Label></p>
        <asp:Literal ID="litSubmitInfo" runat="server"></asp:Literal>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="fuReport" Font-Bold="True">Upload report file <span class="required">*</span></asp:Label><br />
            <div class="dropzone">
                <asp:FileUpload ID="fuReport" runat="server" />
                <span>Choose a report or drag it here</span>
            </div>
            <small>Supported files: PDF, DOC, DOCX, XLS, XLSX, JPG, PNG (max 10 MB)</small>
        </asp:Panel>
        <asp:Panel CssClass="dialog-footer" runat="server">
            <bbui:ActionButton ID="btnConfirmSubmit" runat="server" Text="Submit Report" data-confirm="Submit this report?" data-description="Send the selected file to the DILG office for review." OnClick="btnConfirmSubmit_Click" />
            <bbui:ActionButton ID="btnCancelSubmit" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancelSubmit_Click" />
        </asp:Panel>
    </bbui:Card>

    <bbui:Card ID="pnlDetails" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Activity Details</asp:Label></p>
        <asp:Literal ID="litDetails" runat="server"></asp:Literal>
        <footer class="dialog-footer">
            <bbui:ActionButton
                ID="btnDetailsSubmit"
                runat="server"
                Text="Submit Report"
                OnClick="btnDetailsSubmit_Click" />
            <bbui:ActionButton
                ID="btnCloseDetails"
                runat="server"
                Text="Close"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCloseDetails_Click" />
        </footer>
    </bbui:Card>

    <bbui:FieldRow runat="server" ItemVerticalAlign="Bottom">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search</asp:Label><br />
            <bbui:FormTextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..." AutoPostBack="true" CausesValidation="false" OnTextChanged="btnFilter_Click" data-live="true"></bbui:FormTextBox>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
            <bbui:FormSelect ID="ddlStatus" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="btnFilter_Click">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Not Submitted</asp:ListItem>
                <asp:ListItem>Pending</asp:ListItem>
                <asp:ListItem>Confirmed</asp:ListItem>
                <asp:ListItem>Denied</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
    </bbui:FieldRow>

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvActivities_RowCommand" EmptyDataText="No activities assigned yet.">
            <Columns>
                <asp:TemplateField HeaderText="Activity">
                    <ItemTemplate>
                        <b><%# Ui.H(Eval("activity_name")) %></b><br />
                        <small><%# Ui.H(Eval("description")) %></small>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="frequency" HeaderText="Frequency" />
                <asp:BoundField DataField="period_name" HeaderText="Period" />
                <asp:TemplateField HeaderText="Deadline">
                    <ItemTemplate>
                        <%# Ui.DateTimeText(Eval("submission_deadline")) %>
                        <%# If(Convert.ToDateTime(Eval("submission_deadline")) < DateTime.Now AndAlso CStr(Eval("display_status")) = "Not Submitted", Ui.Badge("Overdue"), "") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Submitted File">
                    <ItemTemplate>
                        <%# If(IsDBNull(Eval("submission_id")), "-", "<a href=""" & ResolveUrl("~/Download.aspx") & "?t=submission&amp;id=" & Eval("submission_id").ToString() & """>" & Ui.H(Eval("file_name")) & "</a><br /><small>" & Ui.DateText(Eval("date_submitted")) & "</small>") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate>
                        <%# Ui.Badge(Eval("display_status")) %>
                        <%# If(CStr(Eval("display_status")) = "Confirmed", "<br /><small>" & Ui.ScoreText(Eval("score")) & " pt</small>", "") %>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Action">
                    <ItemTemplate>
                        <span>
                            <asp:LinkButton runat="server" CssClass="activity-details-action" CommandName="ShowDetails" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false">Details</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="StartSubmit" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false" Visible='<%# CStr(Eval("display_status")) = "Not Submitted" OrElse CStr(Eval("display_status")) = "Denied" %>' Text='<%# If(CStr(Eval("display_status")) = "Denied", "Resubmit", "Submit") %>'></asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
