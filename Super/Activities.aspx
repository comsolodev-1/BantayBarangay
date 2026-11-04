<%@ Page Title="Activities" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Activities.aspx.vb" Inherits="Super_Activities" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="panel-title">
        <div>
            <h1>Activities</h1>
            <p class="sub">Manage reporting activities and deadlines.</p>
        </div>
        <asp:Button ID="btnNew" runat="server" Text="+ New Activity" CssClass="btn" CausesValidation="false" OnClick="btnNew_Click" />
    </div>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="card">
        <h2><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></h2>
        <asp:HiddenField ID="hfActivityId" runat="server" Value="0" />
        <div class="row">
            <div class="field wide"><label>Activity title *</label><asp:TextBox ID="txtName" runat="server" MaxLength="150"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field wide"><label>Description</label><asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field">
                <label>Reporting period (frequency) *</label>
                <asp:DropDownList ID="ddlFrequency" runat="server"></asp:DropDownList>
            </div>
            <div class="field">
                <label>Submission deadline *</label>
                <asp:TextBox ID="txtDeadline" runat="server" TextMode="Date"></asp:TextBox>
            </div>
            <div class="field">
                <label>Visibility</label>
                <asp:CheckBox ID="chkPublic" runat="server" Text="Public (shown on the viewer pages)" Checked="true" />
            </div>
        </div>
        <div class="row">
            <div class="field wide"><label>Requirements (one per line)</label><asp:TextBox ID="txtRequirements" runat="server" TextMode="MultiLine" Rows="4"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field wide">
                <label>Report template file (optional)</label>
                <asp:FileUpload ID="fuTemplate" runat="server" />
                <asp:Literal ID="litCurrentTemplate" runat="server"></asp:Literal>
            </div>
        </div>
        <div class="field wide">
            <label>Assigned barangays *</label>
            <div class="checks">
                <asp:CheckBoxList ID="cblBarangays" runat="server" RepeatLayout="Table" RepeatColumns="3"></asp:CheckBoxList>
            </div>
            <div style="margin-top:6px">
                <asp:Button ID="btnAll" runat="server" Text="Select all" CssClass="btn btn-outline btn-sm" CausesValidation="false" OnClick="btnAll_Click" />
                <asp:Button ID="btnNone" runat="server" Text="Clear" CssClass="btn btn-outline btn-sm" CausesValidation="false" OnClick="btnNone_Click" />
            </div>
        </div>
        <div class="notice notice-ok" style="margin-top:12px">Status is set automatically: Active until the deadline passes, then Closed. Late submissions are still accepted and score 0.5.</div>
        <asp:Button ID="btnSave" runat="server" Text="Save Activity" CssClass="btn" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <asp:Panel ID="pnlPeriod" runat="server" Visible="false" CssClass="card">
        <h2>Add Reporting Period</h2>
        <asp:Literal ID="litPeriodInfo" runat="server"></asp:Literal>
        <asp:HiddenField ID="hfPeriodActivityId" runat="server" Value="0" />
        <div class="row">
            <div class="field">
                <label>Deadline of the new period *</label>
                <asp:TextBox ID="txtNewDeadline" runat="server" TextMode="Date"></asp:TextBox>
            </div>
        </div>
        <asp:Button ID="btnAddPeriod" runat="server" Text="Add Period" CssClass="btn" OnClick="btnAddPeriod_Click" />
        <asp:Button ID="btnCancelPeriod" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancelPeriod_Click" />
    </asp:Panel>

    <div class="row">
        <div class="field wide">
            <label>Search</label>
            <asp:TextBox ID="txtSearch" runat="server" MaxLength="100" placeholder="Search activities..."></asp:TextBox>
        </div>
        <div class="field">
            <label>Status</label>
            <asp:DropDownList ID="ddlStatusFilter" runat="server">
                <asp:ListItem Value="">All</asp:ListItem>
                <asp:ListItem>Active</asp:ListItem>
                <asp:ListItem>Closed</asp:ListItem>
                <asp:ListItem>Archived</asp:ListItem>
            </asp:DropDownList>
        </div>
        <asp:Button ID="btnFilter" runat="server" Text="Filter" CssClass="btn" CausesValidation="false" OnClick="btnFilter_Click" />
    </div>

    <div class="grid-wrap">
        <asp:GridView ID="gvActivities" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" OnRowCommand="gvActivities_RowCommand" EmptyDataText="No activities found.">
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
                        <span class="actions">
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CommandName="AddPeriodRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false">Add Period</asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="danger" CommandName="DeleteRow" CommandArgument='<%# Eval("activity_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this activity? Activities that already have submissions are archived instead.');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
