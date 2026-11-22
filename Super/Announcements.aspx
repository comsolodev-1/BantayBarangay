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

    <bbui:Card ID="pnlForm" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></asp:Label></p>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtTitle" Font-Bold="True">Title *</asp:Label><br /><bbui:FormTextBox ID="txtTitle" runat="server" MaxLength="150"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContent" Font-Bold="True">Content *</asp:Label><br /><bbui:FormTextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5"></bbui:FormTextBox></asp:Panel>
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
                <div class="audience-slot"><span class="all-targets">All Barangays</span>
                <asp:CheckBoxList ID="ddlTargetBarangay" runat="server" RepeatLayout="Flow" CssClass="audience-list" /></div>
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
                <asp:Label runat="server" AssociatedControlID="txtExpiration" Font-Bold="True">Expiration date</asp:Label><br />
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
                <span>Choose an attachment or drag it here</span>
            </div>
            <asp:Literal ID="litCurrentFile" runat="server" />
        </div>
        <footer class="dialog-footer">
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
        </footer>
    </bbui:Card>

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvAnnouncements" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvAnnouncements_RowCommand" EmptyDataText="No announcements yet.">
            <Columns>
                <asp:TemplateField HeaderText="Title">
                    <ItemTemplate><article class="announcement-summary"><b><%# Ui.H(Eval("title")) %></b> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, Ui.Badge("Pinned"), "") %><br/><small><%# Ui.DateText(Eval("date_published")) %></small><p><%# Ui.H(Eval("content")) %></p></article></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Priority">
                    <ItemTemplate><%# Ui.Badge(Eval("priority")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="visibility_type" HeaderText="Visible to" />
                <asp:BoundField DataField="audience" HeaderText="Target barangay" />
                <asp:TemplateField HeaderText="Published">
                    <ItemTemplate><%# Ui.DateText(Eval("date_published")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span>
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false" data-confirm="Delete this announcement?">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
