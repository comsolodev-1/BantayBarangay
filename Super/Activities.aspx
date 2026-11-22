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
    <asp:Literal ID="litPendingPeriods" runat="server" />

    <bbui:Workflow ID="pnlForm" runat="server" Visible="false">
        <bbui:DialogTitle runat="server"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></bbui:DialogTitle>
        <asp:HiddenField ID="hfActivityId" runat="server" Value="0" />
        <asp:HiddenField ID="hfEditPeriodId" runat="server" Value="0" />
        <asp:Literal ID="litEditPeriod" runat="server" />
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
                <label class="field-caption">Visibility</label>
                <asp:CheckBox ID="chkPublic" runat="server" Text="Public (shown on the viewer pages)" Checked="true" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel ID="pnlFrequencyRange" runat="server">
                <asp:Label runat="server" AssociatedControlID="txtFrequencyRange">Frequency range (months)</asp:Label>
                <bbui:FormTextBox ID="txtFrequencyRange" runat="server" TextMode="Number" min="0" max="120" />
                <small>Counted from the activity's creation date. Enter 0 for manual scheduling. General activities are always manual.</small>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtGraceDays">Grace days for this period</asp:Label>
                <bbui:FormTextBox ID="txtGraceDays" runat="server" TextMode="Number" min="0" max="365" />
                <small>Late submissions are accepted during this window. Enter 0 to close at the deadline.</small>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtRequirements" Font-Bold="True">Requirements (one per line)</asp:Label><br /><bbui:FormTextBox ID="txtRequirements" runat="server" TextMode="MultiLine" Rows="4"></bbui:FormTextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="fuTemplate" Font-Bold="True">Report template file (optional)</asp:Label><br />
                <div class="dropzone">
                    <asp:FileUpload ID="fuTemplate" runat="server" />
                </div>
                <asp:Literal ID="litCurrentTemplate" runat="server"></asp:Literal>
            </asp:Panel>
        </bbui:FieldRow>
        <asp:Panel runat="server">
            <label>Assigned barangays *</label>
            <asp:Panel runat="server">
                <bbui:ActionButton ID="btnAll" runat="server" Text="Select all" SkinID="Secondary" CausesValidation="false" OnClick="btnAll_Click" />
                <bbui:ActionButton ID="btnNone" runat="server" Text="Clear" SkinID="Secondary" CausesValidation="false" OnClick="btnNone_Click" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:CheckBoxList ID="cblBarangays" runat="server" RepeatLayout="Table" RepeatColumns="3"></asp:CheckBoxList>
            </asp:Panel>
        </asp:Panel>
        <asp:Panel runat="server" CssClass="status-note" SkinID="Message">Confirmed late reports earn 0.5 points. After the grace period, submissions and resubmissions are closed.</asp:Panel>
        <bbui:DialogFooter runat="server">
            <bbui:ActionButton
                ID="btnSave"
                runat="server"
                Text="Save Activity"
                data-confirm="Save this activity?"
                data-description="Apply the activity details and assignments to the selected barangays."
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

    <bbui:Workflow ID="pnlPeriod" runat="server" Visible="false">
        <bbui:DialogTitle runat="server">Add Reporting Period</bbui:DialogTitle>
        <asp:Literal ID="litPeriodInfo" runat="server"></asp:Literal>
        <p>This adds a new reporting period with its own deadline.</p>
        <asp:HiddenField ID="hfPeriodActivityId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtNewDeadline" Font-Bold="True">Deadline of the new period *</asp:Label><br />
                <bbui:FormTextBox ID="txtNewDeadline" runat="server" TextMode="Date"></bbui:FormTextBox>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtNewGraceDays">Grace days</asp:Label>
                <bbui:FormTextBox ID="txtNewGraceDays" runat="server" TextMode="Number" min="0" max="365" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:DialogFooter runat="server">
            <bbui:ActionButton
                ID="btnAddPeriod"
                runat="server"
                Text="Add Period"
                SkinID="PeriodAction"
                data-confirm="Add a new reporting period?"
                OnClick="btnAddPeriod_Click" />
            <bbui:ActionButton
                ID="btnCancelPeriod"
                runat="server"
                Text="Cancel"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancelPeriod_Click" />
        </bbui:DialogFooter>
    </bbui:Workflow>

    <!-- Extend the deadline of an existing reporting period. -->
    <bbui:Workflow ID="pnlExtend" runat="server" Visible="false">
        <bbui:DialogTitle runat="server"><asp:Literal ID="litExtensionTitle" runat="server" /></bbui:DialogTitle>
        <asp:Literal ID="litExtensionDetails" runat="server" />
        <asp:Literal ID="litExtensionMessage" runat="server" />
        <asp:HiddenField ID="hfExtendActivityId" runat="server" />
        <asp:HiddenField ID="hfDraftPeriodId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel ID="pnlChooseExtendPeriod" runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlExtendPeriod">Reporting period</asp:Label>
                <bbui:FormSelect ID="ddlExtendPeriod" runat="server" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtExtension">New deadline</asp:Label>
                <bbui:FormTextBox ID="txtExtension" runat="server" TextMode="DateTimeLocal" step="1" />
            </asp:Panel>
            <asp:Panel ID="pnlDraftGrace" runat="server" Visible="false">
                <asp:Label runat="server" AssociatedControlID="txtDraftGraceDays">Grace days</asp:Label>
                <bbui:FormTextBox ID="txtDraftGraceDays" runat="server" TextMode="Number" min="0" max="365" />
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:DialogFooter runat="server">
            <bbui:ActionButton
                ID="btnCancelExtension"
                runat="server"
                Text="Cancel"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancelExtension_Click" />
            <bbui:ActionButton
                ID="btnExtend"
                runat="server"
                Text="Extend Report Submission"
                SkinID="PeriodAction"
                OnClick="btnExtend_Click" />
        </bbui:DialogFooter>
    </bbui:Workflow>

    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search</asp:Label><br />
            <bbui:FormTextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..." CausesValidation="false"></bbui:FormTextBox>
            <bbui:ActionButton runat="server" Text="Search" SkinID="Secondary" CausesValidation="false" OnClick="btnFilter_Click" />
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatusFilter" Font-Bold="True">Status</asp:Label><br />
            <bbui:FormSelect ID="ddlStatusFilter" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="btnFilter_Click">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Open</asp:ListItem>
                <asp:ListItem>Grace Period</asp:ListItem>
                <asp:ListItem>Closed</asp:ListItem>
                <asp:ListItem>Awaiting Deadline</asp:ListItem>
                <asp:ListItem>Archived</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
    </bbui:FieldRow>

    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <bbui:DataGrid ID="gvActivities" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvActivities_RowCommand" EmptyDataText="No activities found.">
            <Columns>
                <asp:TemplateField HeaderText="Activity">
                    <ItemTemplate>
                        <b><%# Ui.H(Eval("activity_name")) %></b><br />
                        <small><%# Ui.H(Eval("description")) %></small>
                    </ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="frequency" HeaderText="Frequency" />
                <asp:BoundField DataField="period_name" HeaderText="Reporting Period" />
                <asp:TemplateField HeaderText="Deadline">
                    <ItemTemplate><%# If(IsDBNull(Eval("submission_deadline")), "Not set", Ui.DateTimeText(Eval("submission_deadline"))) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Cut-off">
                    <ItemTemplate><%# If(IsDBNull(Eval("cutoff")), "-", Ui.DateTimeText(Eval("cutoff"))) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="barangay_count" HeaderText="Barangays" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("period_status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Public">
                    <ItemTemplate><%# If(Convert.ToInt32(Eval("is_public")) = 1, Ui.Badge("Public"), Ui.Badge("Private")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span class="activity-actions">
                            <bbui:ActionLink runat="server" CommandName="EditRow" CommandArgument='<%# Eval("activity_id").ToString() & ":" & Eval("period_id").ToString() %>' CausesValidation="false"
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" AndAlso Not IsDBNull(Eval("submission_deadline")) %>'>Edit</bbui:ActionLink>
                            <bbui:ActionLink runat="server" SkinID="PeriodAction" CommandName="DraftRow"
                                CommandArgument='<%# Eval("activity_id").ToString() & ":" & Eval("period_id").ToString() %>' CausesValidation="false"
                                Visible='<%# CStr(Eval("period_status")) = "Awaiting Deadline" %>'>Set Deadline</bbui:ActionLink>
                            <bbui:ActionLink runat="server" SkinID="PeriodAction" CommandName="AddPeriodRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false"
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" %>'>Add Period</bbui:ActionLink>
                            <bbui:ActionLink
                                runat="server"
                                SkinID="PeriodAction"
                                CommandName="ExtendRow"
                                CommandArgument='<%# Eval("activity_id").ToString() & ":" & Eval("period_id").ToString() %>'
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" AndAlso Not IsDBNull(Eval("submission_deadline")) %>'
                                CausesValidation="false">Extend Report Submission</bbui:ActionLink>
                            <bbui:ActionLink
                                runat="server"
                                SkinID="Danger"
                                CommandName="DeleteRow"
                                CommandArgument='<%# Eval("activity_id") %>'
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" %>'
                                CausesValidation="false"
                                data-confirm='<%# "Delete this activity? " & Eval("submission_count").ToString() & " submission(s) will be removed from reports and kept for audit." %>'>Delete</bbui:ActionLink>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </bbui:DataGrid>
    </bbui:Card>
</asp:Content>
