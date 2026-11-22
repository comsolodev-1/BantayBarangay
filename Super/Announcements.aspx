<%@ Page Title="Announcements" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Announcements.aspx.vb" Inherits="Super_Announcements" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Announcements</asp:Label></p>
            <p>Post notices for the public, a role, or a specific barangay.</p>
        </asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ New Announcement" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Workflow ID="pnlForm" runat="server" Visible="false">
        <bbui:DialogTitle runat="server"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></bbui:DialogTitle>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtTitle" Font-Bold="True">Title <span class="required">*</span></asp:Label><br /><bbui:FormTextBox ID="txtTitle" runat="server" MaxLength="150" aria-required="true"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContent" Font-Bold="True">Description <span class="required">*</span></asp:Label><br /><bbui:FormTextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5" aria-required="true"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlPriority" Font-Bold="True">Priority</asp:Label><br />
                <bbui:FormSelect ID="ddlPriority" runat="server">
                    <asp:ListItem>Low</asp:ListItem>
                    <asp:ListItem Selected="True">Medium</asp:ListItem>
                    <asp:ListItem>High</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlVisibility" Font-Bold="True">Visible to</asp:Label><br />
                <bbui:FormSelect ID="ddlVisibility" runat="server">
                    <asp:ListItem Value="All">Everyone (public)</asp:ListItem>
                    <asp:ListItem Value="Specific Role">Barangay admins</asp:ListItem>
                    <asp:ListItem Value="Specific Barangay">Specific barangay</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlTargetBarangay" Font-Bold="True">Target barangay</asp:Label><br />
                <details><summary>Select barangays for Specific barangay visibility</summary>
                <asp:CheckBoxList ID="ddlTargetBarangay" runat="server" RepeatLayout="Flow" CssClass="audience-list" /></details>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
                <bbui:FormSelect ID="ddlStatus" runat="server">
                    <asp:ListItem>Draft</asp:ListItem>
                    <asp:ListItem Selected="True">Published</asp:ListItem>

                </bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtExpiration" Font-Bold="True">Expiration date<asp:PlaceHolder ID="expirationRequiredMark" runat="server" Visible="false"> <span class="required">*</span></asp:PlaceHolder></asp:Label><br />
                <bbui:FormTextBox ID="txtExpiration" runat="server" TextMode="Date"></bbui:FormTextBox>
            </asp:Panel>
            <asp:Panel runat="server">
                <label>Pin</label>
                <asp:CheckBox ID="chkPinned" runat="server" Text="Pin to top" />
            </asp:Panel>

        </bbui:FieldRow>
        <div class="popup-section">
            <asp:Label runat="server" AssociatedControlID="fuAttachment">Attachment (optional)</asp:Label>
            <div class="dropzone">
                <asp:FileUpload ID="fuAttachment" runat="server" />
            </div>
            <asp:Literal ID="litCurrentFile" runat="server" />
        </div>
        <bbui:DialogFooter runat="server">
            <bbui:ActionButton
                ID="btnSave"
                runat="server"
                Text="Save Announcement"
                data-confirm="Save this announcement?"
                data-description="Save the content, audience and publication status you selected."
                OnClick="btnSave_Click" />
            <bbui:ActionButton
                ID="btnCancel"
                runat="server"
                Text="Cancel"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancel_Click" />
        </bbui:DialogFooter>
    </bbui:Workflow>

    <bbui:FieldRow runat="server" CssClass="priority-filter">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlPriorityFilter">Filter by priority</asp:Label>
            <bbui:FormSelect ID="ddlPriorityFilter" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="PriorityFilter_Changed">
                <asp:ListItem Value="">All priorities</asp:ListItem>
                <asp:ListItem>High</asp:ListItem>
                <asp:ListItem>Medium</asp:ListItem>
                <asp:ListItem>Low</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
    </bbui:FieldRow>
    <bbui:Card runat="server" CssClass="announcement-table-scroll" role="region" aria-label="Announcements table" TabIndex="0" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <bbui:DataGrid ID="gvAnnouncements" runat="server" MinimumWidth="736px" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvAnnouncements_RowCommand" EmptyDataText="No announcements match this priority.">
            <Columns>
                <asp:TemplateField HeaderText="Title" HeaderStyle-Width="34%">
                    <ItemTemplate><article class="announcement-summary"><b><%# Ui.H(Eval("title")) %></b> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, Ui.Badge("Pinned"), "") %><br/><small><%# Ui.DateText(Eval("date_published")) %></small><p><%# Ui.H(Eval("content")) %></p></article></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Priority" HeaderStyle-Wrap="False" ItemStyle-Wrap="False">
                    <ItemTemplate><%# Ui.Badge(Eval("priority")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="visibility_type" HeaderText="Visible to" HeaderStyle-Wrap="False" ItemStyle-Wrap="False" />
                <asp:BoundField DataField="audience" HeaderText="Target barangay" HeaderStyle-Wrap="False" ItemStyle-Wrap="False" />
                <asp:TemplateField HeaderText="Published" HeaderStyle-Wrap="False" ItemStyle-Wrap="False">
                    <ItemTemplate><%# Ui.DateText(Eval("date_published")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status" HeaderStyle-Wrap="False" ItemStyle-Wrap="False">
                    <ItemTemplate><%# Ui.Badge(Eval("status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions" HeaderStyle-Wrap="False" ItemStyle-Wrap="False">
                    <ItemTemplate>
                        <span>
                            <bbui:ActionLink runat="server" CommandName="EditRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false">Edit</bbui:ActionLink>
                            <bbui:ActionLink runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false" data-confirm="Delete this announcement?">Delete</bbui:ActionLink>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </bbui:DataGrid>
    </bbui:Card>
</asp:Content>
