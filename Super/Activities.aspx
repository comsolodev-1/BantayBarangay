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

    <bbui:Card ID="pnlForm" CssClass="workflow" runat="server" Visible="false">
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
                <label class="field-caption">Visibility</label>
                <asp:CheckBox ID="chkPublic" runat="server" Text="Public (shown on the viewer pages)" Checked="true" />
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
                    <span>Choose a template or drag it here</span>
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
        <asp:Panel runat="server" CssClass="status-note" SkinID="Message">Status is set automatically: Active until the deadline passes, then Closed. Late submissions are still accepted and score 0.5.</asp:Panel>
        <footer class="dialog-footer">
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
        </footer>
    </bbui:Card>

    <bbui:Card ID="pnlPeriod" CssClass="workflow" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2">Extend Activity Deadline</asp:Label></p>
        <asp:Literal ID="litPeriodInfo" runat="server"></asp:Literal>
        <p>This adds a new reporting period with its own deadline.</p>
        <asp:HiddenField ID="hfPeriodActivityId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtNewDeadline" Font-Bold="True">Deadline of the new period *</asp:Label><br />
                <bbui:FormTextBox ID="txtNewDeadline" runat="server" TextMode="Date"></bbui:FormTextBox>
            </asp:Panel>
        </bbui:FieldRow>
        <footer class="dialog-footer">
            <bbui:ActionButton
                ID="btnAddPeriod"
                runat="server"
                Text="Extend Activity Deadline"
                SkinID="ActivityPeriod"
                data-confirm="Add a new reporting period?"
                OnClick="btnAddPeriod_Click" />
            <bbui:ActionButton
                ID="btnCancelPeriod"
                runat="server"
                Text="Cancel"
                SkinID="Secondary"
                CausesValidation="false"
                OnClick="btnCancelPeriod_Click" />
        </footer>
    </bbui:Card>

    <!-- Extend the deadline of an existing reporting period. -->
    <bbui:Card ID="pnlExtend" CssClass="workflow" runat="server" Visible="false">
        <p role="heading" aria-level="2">Extend Report Submission</p>
        <p>Choose an existing reporting period and set a later submission deadline.</p>
        <asp:Literal ID="litExtensionMessage" runat="server" />
        <asp:HiddenField ID="hfExtendActivityId" runat="server" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlExtendPeriod">Reporting period</asp:Label>
                <bbui:FormSelect ID="ddlExtendPeriod" runat="server" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtExtension">New deadline</asp:Label>
                <bbui:FormTextBox ID="txtExtension" runat="server" TextMode="DateTimeLocal" />
            </asp:Panel>
        </bbui:FieldRow>
        <footer class="dialog-footer">
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
                SkinID="SubmissionExtension"
                OnClick="btnExtend_Click" />
        </footer>
    </bbui:Card>

    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="txtSearch" Font-Bold="True">Search</asp:Label><br />
            <bbui:FormTextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..." AutoPostBack="true" CausesValidation="false" OnTextChanged="btnFilter_Click" data-live="true"></bbui:FormTextBox>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlStatusFilter" Font-Bold="True">Status</asp:Label><br />
            <bbui:FormSelect ID="ddlStatusFilter" runat="server" AutoPostBack="true" CausesValidation="false" OnSelectedIndexChanged="btnFilter_Click">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Active</asp:ListItem>
                <asp:ListItem>Closed</asp:ListItem>
                <asp:ListItem>Archived</asp:ListItem>
            </bbui:FormSelect>
        </asp:Panel>
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
                        <span class="activity-actions">
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false"
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" %>'>Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="activity-period-action" CommandName="AddPeriodRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false"
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" %>'>Extend Activity Deadline</asp:LinkButton>
                            <asp:LinkButton
                                runat="server"
                                CssClass="submission-extension-action"
                                CommandName="ExtendRow"
                                CommandArgument='<%# Eval("activity_id") %>'
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" %>'
                                CausesValidation="false">Extend Report Submission</asp:LinkButton>
                            <asp:LinkButton
                                runat="server"
                                SkinID="Danger"
                                CommandName="DeleteRow"
                                CommandArgument='<%# Eval("activity_id") %>'
                                Visible='<%# CStr(Eval("activity_status")) <> "Archived" %>'
                                CausesValidation="false"
                                data-confirm='<%# "Delete this activity? " & Eval("submission_count").ToString() & " submission(s) will be removed from reports and kept for audit." %>'>Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
