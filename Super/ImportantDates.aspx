<%@ Page Title="Important Dates" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="ImportantDates.aspx.vb" Inherits="Super_ImportantDates" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="panel-title">
        <div>
            <h1>Important Dates</h1>
            <p class="sub">Meetings, holidays, deadlines and events shown on the calendar.</p>
        </div>
        <asp:Button ID="btnNew" runat="server" Text="+ Add Date" CssClass="btn" CausesValidation="false" OnClick="btnNew_Click" />
    </div>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="card">
        <h2><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></h2>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <div class="row">
            <div class="field wide"><label>Title *</label><asp:TextBox ID="txtTitle" runat="server" MaxLength="150"></asp:TextBox></div>
            <div class="field">
                <label>Type</label>
                <asp:DropDownList ID="ddlType" runat="server">
                    <asp:ListItem>Meeting</asp:ListItem>
                    <asp:ListItem>Deadline</asp:ListItem>
                    <asp:ListItem>Holiday</asp:ListItem>
                    <asp:ListItem>Event</asp:ListItem>
                    <asp:ListItem>Training</asp:ListItem>
                </asp:DropDownList>
            </div>
        </div>
        <div class="row">
            <div class="field wide"><label>Description</label><asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field"><label>Date *</label><asp:TextBox ID="txtDate" runat="server" TextMode="Date"></asp:TextBox></div>
            <div class="field"><label>Start time</label><asp:TextBox ID="txtStart" runat="server" TextMode="Time"></asp:TextBox></div>
            <div class="field"><label>End time</label><asp:TextBox ID="txtEnd" runat="server" TextMode="Time"></asp:TextBox></div>
            <div class="field wide"><label>Location</label><asp:TextBox ID="txtLocation" runat="server" MaxLength="255"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field">
                <label>Visible to</label>
                <asp:DropDownList ID="ddlVisibility" runat="server">
                    <asp:ListItem Value="All">Everyone (public)</asp:ListItem>
                    <asp:ListItem Value="Specific Role">Specific role</asp:ListItem>
                    <asp:ListItem Value="Specific Barangay">Specific barangay</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="field">
                <label>Target role</label>
                <asp:DropDownList ID="ddlRole" runat="server">
                    <asp:ListItem>Barangay Admin</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="field">
                <label>Target barangay</label>
                <asp:DropDownList ID="ddlTargetBarangay" runat="server"></asp:DropDownList>
            </div>
            <div class="field"><label>Reminder date (optional)</label><asp:TextBox ID="txtReminder" runat="server" TextMode="Date"></asp:TextBox></div>
        </div>
        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <div class="grid-wrap">
        <asp:GridView ID="gvDates" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" OnRowCommand="gvDates_RowCommand" EmptyDataText="No dates added yet.">
            <Columns>
                <asp:TemplateField HeaderText="Date">
                    <ItemTemplate><%# Ui.DateText(Eval("event_date")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="title" HeaderText="Title" />
                <asp:BoundField DataField="event_type" HeaderText="Type" />
                <asp:BoundField DataField="location" HeaderText="Location" />
                <asp:BoundField DataField="visibility_type" HeaderText="Visible to" />
                <asp:TemplateField HeaderText="Status">
                    <ItemTemplate><%# Ui.Badge(Eval("status")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Actions">
                    <ItemTemplate>
                        <span class="actions">
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="danger" CommandName="DeleteRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this date?');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
