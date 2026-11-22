<%@ Page Title="My Activities" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="MyActivities.aspx.vb" Inherits="Barangay_MyActivities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">My Activities</asp:Label></p>
    <p>Reporting activities assigned to your barangay.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Workflow ID="pnlSubmit" runat="server" Visible="false">
        <bbui:DialogTitle runat="server">Submit Report</bbui:DialogTitle>
        <asp:Literal ID="litSubmitInfo" runat="server"></asp:Literal>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="fuReport" Font-Bold="True">Upload report file <span class="required">*</span></asp:Label><br />
            <div class="dropzone">
                <asp:FileUpload ID="fuReport" runat="server" />
            </div>
            <small>Supported files: PDF, DOC, DOCX, XLS, XLSX, JPG, PNG (max 10 MB)</small>
        </asp:Panel>
        <bbui:DialogFooter runat="server">
            <bbui:ActionButton ID="btnConfirmSubmit" runat="server" Text="Submit Report" data-confirm="Submit this report?" data-description="Send the selected file to the DILG office for review." OnClick="btnConfirmSubmit_Click" />
            <bbui:ActionButton ID="btnCancelSubmit" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancelSubmit_Click" />
        </bbui:DialogFooter>
    </bbui:Workflow>

    <bbui:Workflow ID="pnlDetails" runat="server" Visible="false">
        <bbui:DialogTitle runat="server">Activity Details</bbui:DialogTitle>
        <asp:Literal ID="litDetails" runat="server"></asp:Literal>
        <bbui:DialogFooter runat="server">
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
        </bbui:DialogFooter>
    </bbui:Workflow>

    <bbui:FieldRow runat="server" ItemVerticalAlign="Bottom">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search</asp:Label><br />
            <bbui:FormTextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..." CausesValidation="false"></bbui:FormTextBox>
            <bbui:ActionButton runat="server" Text="Search" SkinID="Secondary" CausesValidation="false" OnClick="btnFilter_Click" />
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
        <bbui:DataGrid ID="gvActivities" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvActivities_RowCommand" EmptyDataText="No activities assigned yet.">
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
                        <br /><small>Cut-off <%# Ui.DateTimeText(Eval("cutoff")) %></small>
                        <br /><%# Ui.Badge(Eval("period_status")) %>
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
                            <bbui:ActionLink runat="server" CssClass="activity-details-action" CommandName="ShowDetails" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false">Details</bbui:ActionLink>
                            <bbui:ActionLink runat="server" CommandName="StartSubmit" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false" Visible='<%# Assignments.CanSubmit(Eval("accepting"), Eval("display_status")) %>' Text='<%# If(CStr(Eval("display_status")) = "Denied", "Resubmit", "Submit") %>'></bbui:ActionLink>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </bbui:DataGrid>
    </bbui:Card>
</asp:Content>
