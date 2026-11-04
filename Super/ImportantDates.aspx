<%@ Page Title="Important Dates" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="ImportantDates.aspx.vb" Inherits="Super_ImportantDates" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Important Dates</asp:Label></p>
            <p>Meetings, holidays, deadlines and events shown on the calendar.</p>
        </asp:Panel>
        <asp:Button ID="btnNew" runat="server" Text="+ Add Date" CausesValidation="false" OnClick="btnNew_Click" />
    </bbui:FieldRow>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <bbui:Card ID="pnlForm" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2"><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></asp:Label></p>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtTitle" Font-Bold="True">Title *</asp:Label><br /><asp:TextBox ID="txtTitle" runat="server" MaxLength="150"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlType" Font-Bold="True">Type</asp:Label><br />
                <asp:DropDownList ID="ddlType" runat="server">
                    <asp:ListItem>Meeting</asp:ListItem>
                    <asp:ListItem>Deadline</asp:ListItem>
                    <asp:ListItem>Holiday</asp:ListItem>
                    <asp:ListItem>Event</asp:ListItem>
                    <asp:ListItem>Training</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtDescription" Font-Bold="True">Description</asp:Label><br /><asp:TextBox ID="txtDescription" runat="server" TextMode="MultiLine" Rows="3"></asp:TextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtDate" Font-Bold="True">Date *</asp:Label><br /><asp:TextBox ID="txtDate" runat="server" TextMode="Date"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtStart" Font-Bold="True">Start time</asp:Label><br /><asp:TextBox ID="txtStart" runat="server" TextMode="Time"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtEnd" Font-Bold="True">End time</asp:Label><br /><asp:TextBox ID="txtEnd" runat="server" TextMode="Time"></asp:TextBox></asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtLocation" Font-Bold="True">Location</asp:Label><br /><asp:TextBox ID="txtLocation" runat="server" MaxLength="255"></asp:TextBox></asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlVisibility" Font-Bold="True">Visible to</asp:Label><br />
                <asp:DropDownList ID="ddlVisibility" runat="server">
                    <asp:ListItem Value="All">Everyone (public)</asp:ListItem>
                    <asp:ListItem Value="Specific Role">Specific role</asp:ListItem>
                    <asp:ListItem Value="Specific Barangay">Specific barangay</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlRole" Font-Bold="True">Target role</asp:Label><br />
                <asp:DropDownList ID="ddlRole" runat="server">
                    <asp:ListItem>Barangay Admin</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlTargetBarangay" Font-Bold="True">Target barangay</asp:Label><br />
                <asp:DropDownList ID="ddlTargetBarangay" runat="server"></asp:DropDownList>
            </asp:Panel>
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtReminder" Font-Bold="True">Reminder date (optional)</asp:Label><br /><asp:TextBox ID="txtReminder" runat="server" TextMode="Date"></asp:TextBox></asp:Panel>
        </bbui:FieldRow>
        <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancel_Click" />
    </bbui:Card>

    <asp:Panel runat="server" SkinID="GridArea">
        <asp:GridView ID="gvDates" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvDates_RowCommand" EmptyDataText="No dates added yet.">
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
                        <span>
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("date_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this date?');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </asp:Panel>
</asp:Content>
