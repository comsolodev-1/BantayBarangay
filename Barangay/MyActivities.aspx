<%@ Page Title="My Activities" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="MyActivities.aspx.vb" Inherits="Barangay_MyActivities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>My Activities</h1>
    <p>Reporting activities assigned to your barangay.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlSubmit" runat="server" Visible="false" BorderWidth="1px" BorderColor="#A8D5B5" BorderStyle="Solid" BackColor="White">
        <h2>Submit Report</h2>
        <asp:Literal ID="litSubmitInfo" runat="server"></asp:Literal>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="fuReport" Font-Bold="True">Upload report file (PDF, DOC, DOCX, XLS, XLSX, JPG, PNG - max 10 MB) *</asp:Label><br />
            <asp:FileUpload ID="fuReport" runat="server" />
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Button ID="btnConfirmSubmit" runat="server" Text="Submit Report" OnClick="btnConfirmSubmit_Click" />
            <asp:Button ID="btnCancelSubmit" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancelSubmit_Click" />
        </asp:Panel>
    </asp:Panel>

    <asp:Panel ID="pnlDetails" runat="server" Visible="false" BorderWidth="1px" BorderColor="#A8D5B5" BorderStyle="Solid" BackColor="White">
        <h2>Activity Details</h2>
        <asp:Literal ID="litDetails" runat="server"></asp:Literal>
        <asp:Button ID="btnCloseDetails" runat="server" Text="Close" SkinID="Secondary" CausesValidation="false" OnClick="btnCloseDetails_Click" />
    </asp:Panel>

    <asp:Panel runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search</asp:Label><br />
            <asp:TextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..."></asp:TextBox>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
            <asp:DropDownList ID="ddlStatus" runat="server">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Not Submitted</asp:ListItem>
                <asp:ListItem>Pending</asp:ListItem>
                <asp:ListItem>Confirmed</asp:ListItem>
                <asp:ListItem>Denied</asp:ListItem>
            </asp:DropDownList>
        </asp:Panel>
        <asp:Button ID="btnFilter" runat="server" Text="Filter" CausesValidation="false" OnClick="btnFilter_Click" />
    </asp:Panel>

    <asp:Panel runat="server" SkinID="GridArea">
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
                        <%# Ui.DateText(Eval("submission_deadline")) %>
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
                            <asp:LinkButton runat="server" CommandName="ShowDetails" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false">Details</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="StartSubmit" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false" Visible='<%# CStr(Eval("display_status")) = "Not Submitted" OrElse CStr(Eval("display_status")) = "Denied" %>' Text='<%# If(CStr(Eval("display_status")) = "Denied", "Resubmit", "Submit") %>'></asp:LinkButton>
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="RemoveSubmission" CommandArgument='<%# Eval("period_id") %>' CausesValidation="false" Visible='<%# CStr(Eval("display_status")) = "Pending" %>' OnClientClick="return confirm('Remove this submission?');">Remove</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </asp:Panel>
</asp:Content>
