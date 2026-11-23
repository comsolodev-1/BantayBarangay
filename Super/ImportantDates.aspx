<%@ Page Title="Important Dates" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="ImportantDates.aspx.vb" Inherits="Super_ImportantDates" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Important Dates</asp:Label></p>
            <p>Meetings, holidays, deadlines and events shown on the calendar.</p>
        </asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ Add Date" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Workflow ID="pnlForm" runat="server" Visible="false">
        <bbui:DialogTitle runat="server"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></bbui:DialogTitle>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtTitle" Font-Bold="True">Title <span class="required">*</span></asp:Label><br /><bbui:FormTextBox ID="txtTitle" runat="server" MaxLength="150" aria-required="true"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlType" Font-Bold="True">Type <span class="required">*</span></asp:Label><br />
                <bbui:FormSelect ID="ddlType" runat="server">
                    <asp:ListItem>Meeting</asp:ListItem>
                    <asp:ListItem>Deadline</asp:ListItem>
                    <asp:ListItem>Holiday</asp:ListItem>
                    <asp:ListItem>Event</asp:ListItem>
                    <asp:ListItem>Training</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtDescription" Font-Bold="True">Description</asp:Label><br /><bbui:FormTextBox placeholder="Include the purpose and any instructions for attendees." ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtDate" Font-Bold="True">Date <span class="required">*</span></asp:Label><br /><bbui:FormTextBox ID="txtDate" runat="server" TextMode="Date" AutoPostBack="true" CausesValidation="false" aria-required="true"></bbui:FormTextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtStart" Font-Bold="True">Start time</asp:Label><br /><bbui:EventTimePicker ID="txtStart" runat="server" AutoPostBack="true" CausesValidation="false" /></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtEnd" Font-Bold="True">End time</asp:Label><br /><bbui:EventTimePicker ID="txtEnd" runat="server" /></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtLocation" Font-Bold="True">Location</asp:Label><br /><bbui:FormTextBox ID="txtLocation" runat="server" MaxLength="255"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow ID="editAudienceFields" runat="server" Visible="false">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlVisibility" Font-Bold="True">Visible to <span class="required">*</span></asp:Label><br />
                <bbui:FormSelect ID="ddlVisibility" runat="server">
                    <asp:ListItem Value="All">Everyone (public)</asp:ListItem>
                    <asp:ListItem Value="Specific Role">Barangay admins</asp:ListItem>
                    <asp:ListItem Value="Specific Barangay">Specific barangay</asp:ListItem>
                </bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlTargetBarangay" Font-Bold="True">Target barangay <span class="required audience-required">*</span></asp:Label><br />
                <details><summary>Select a barangay for Specific barangay visibility</summary><asp:CheckBoxList ID="ddlTargetBarangay" runat="server" RepeatLayout="Flow" CssClass="audience-list" /></details>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtReminder" Font-Bold="True">Reminder Date</asp:Label><br /><bbui:FormTextBox ID="txtReminder" runat="server" TextMode="Date"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:DialogFooter runat="server">
            <bbui:ActionButton
                ID="btnSave"
                runat="server"
                Text="Save"
                data-confirm="Save this calendar date?"
                data-description="Save the event details to the calendar."
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

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <bbui:DataGrid ID="gvDates" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvDates_RowCommand" EmptyDataText="No dates added yet.">
            <Columns>
                <asp:TemplateField HeaderText="Date">
                    <ItemTemplate><%# Ui.DateText(Eval("event_date")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="title" HeaderText="Title" />
                <asp:BoundField DataField="event_type" HeaderText="Type" />
                <asp:BoundField DataField="location" HeaderText="Location" />
                <asp:BoundField DataField="visibility_type" HeaderText="Visible to" />
                <asp:BoundField DataField="audience" HeaderText="Target barangay" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span>
                            <bbui:ActionLink runat="server" CommandName="EditRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false">Edit</bbui:ActionLink>
                            <bbui:ActionLink runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false" data-confirm="Delete this date?">Delete</bbui:ActionLink>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </bbui:DataGrid>
    </bbui:Card>
    <bbui:RecordPager ID="pager" runat="server" OnPageChanged="Pager_PageChanged" />
</asp:Content>
