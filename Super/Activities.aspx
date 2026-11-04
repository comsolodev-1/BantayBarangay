<%@ Page Title="Activities" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Activities.aspx.vb" Inherits="Super_Activities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Activities</asp:Label></p>
            <p>Manage reporting activities and deadlines.</p>
        </asp:Panel>
        <bbui:ActionButton ID="btnNew" runat="server" Text="+ New Activity" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlForm" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></asp:Label></p>
        <asp:HiddenField ID="hfActivityId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtName" Font-Bold="True">Activity title *</asp:Label><br /><bbui:FormTextBox ID="txtName" runat="server" MaxLength="150"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtDescription" Font-Bold="True">Description</asp:Label><br /><bbui:FormTextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlFrequency" Font-Bold="True">Reporting period (frequency) *</asp:Label><br />
                <bbui:FormSelect ID="ddlFrequency" runat="server"></bbui:FormSelect>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtDeadline" Font-Bold="True">Submission deadline *</asp:Label><br />
                <bbui:FormTextBox ID="txtDeadline" runat="server" TextMode="Date"></bbui:FormTextBox>
            </asp:Panel>
            <asp:Panel runat="server">
                <label>Visibility</label>
                <asp:CheckBox ID="chkPublic" runat="server" Text="Public (shown on the viewer pages)" Checked="true" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtRequirements" Font-Bold="True">Requirements (one per line)</asp:Label><br /><bbui:FormTextBox ID="txtRequirements" runat="server" TextMode="MultiLine" Rows="4"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="fuTemplate" Font-Bold="True">Report template file (optional)</asp:Label><br />
                <asp:FileUpload ID="fuTemplate" runat="server" />
                <asp:Literal ID="litCurrentTemplate" runat="server"></asp:Literal>
            </asp:Panel>
        </bbui:FieldRow>
        <asp:Panel runat="server">
            <label>Assigned barangays *</label>
            <asp:Panel runat="server">
                <asp:CheckBoxList ID="cblBarangays" runat="server" RepeatLayout="Table" RepeatColumns="3"></asp:CheckBoxList>
            </asp:Panel>
            <asp:Panel runat="server">
                <bbui:ActionButton ID="btnAll" runat="server" Text="Select all" SkinID="Secondary" CausesValidation="false" OnClick="btnAll_Click" />
                <bbui:ActionButton ID="btnNone" runat="server" Text="Clear" SkinID="Secondary" CausesValidation="false" OnClick="btnNone_Click" />
            </asp:Panel>
        </asp:Panel>
        <asp:Panel runat="server" SkinID="Message">Status is set automatically: Active until the deadline passes, then Closed. Late submissions are still accepted and score 0.5.</asp:Panel>
        <bbui:ActionButton ID="btnSave" runat="server" Text="Save Activity" OnClick="btnSave_Click" />
        <bbui:ActionButton ID="btnCancel" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancel_Click" />
    </bbui:Card>

    <bbui:Card ID="pnlPeriod" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Add Reporting Period</asp:Label></p>
        <asp:Literal ID="litPeriodInfo" runat="server"></asp:Literal>
        <asp:HiddenField ID="hfPeriodActivityId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtNewDeadline" Font-Bold="True">Deadline of the new period *</asp:Label><br />
                <bbui:FormTextBox ID="txtNewDeadline" runat="server" TextMode="Date"></bbui:FormTextBox>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:ActionButton ID="btnAddPeriod" runat="server" Text="Add Period" OnClick="btnAddPeriod_Click" />
        <bbui:ActionButton ID="btnCancelPeriod" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancelPeriod_Click" />
    </bbui:Card>

    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search</asp:Label><br />
            <bbui:FormTextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..."></bbui:FormTextBox>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatusFilter" Font-Bold="True">Status</asp:Label><br />
            <bbui:FormSelect ID="ddlStatusFilter" runat="server">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Active</asp:ListItem>
                <asp:ListItem>Closed</asp:ListItem>
                <asp:ListItem>Archived</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
        <bbui:ActionButton ID="btnFilter" runat="server" Text="Filter" CausesValidation="false" OnClick="btnFilter_Click" />
    </bbui:FieldRow>

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvActivities_RowCommand" EmptyDataText="No activities found.">
            <Columns>
                <asp:TemplateField HeaderText="Activity">
                    <ItemTemplate>
                        <b><%# Ui.H(Eval("activity_name")) %></b><br />
                        <small><%# Ui.H(Eval("description")) %></small>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="frequency" HeaderText="Frequency" />
                <asp:TemplateField HeaderText="Latest Deadline">
                    <ItemTemplate><%# Ui.DateText(Eval("latest_deadline")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="barangay_count" HeaderText="Barangays" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("activity_status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Public">
                    <ItemTemplate><%# If(Convert.ToInt32(Eval("is_public")) = 1, Ui.Badge("Public"), Ui.Badge("Private")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span>
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="AddPeriodRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false">Add Period</asp:LinkButton>
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this activity? Activities that already have submissions are archived instead.');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
