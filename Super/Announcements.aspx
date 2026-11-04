<%@ Page Title="Announcements" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Announcements.aspx.vb" Inherits="Super_Announcements" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <asp:Panel runat="server">
        <asp:Panel runat="server">
            <h1>Announcements</h1>
            <p>Post notices for the public, a role, or a specific barangay.</p>
        </asp:Panel>
        <asp:Button ID="btnNew" runat="server" Text="+ New Announcement" CausesValidation="false" OnClick="btnNew_Click" />
    </asp:Panel>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" BorderWidth="1px" BorderColor="#A8D5B5" BorderStyle="Solid" BackColor="White">
        <h2><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></h2>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <asp:Panel runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtTitle" Font-Bold="True">Title *</asp:Label><br /><asp:TextBox ID="txtTitle" runat="server" MaxLength="150"></asp:TextBox></asp:Panel>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Panel runat="server"><asp:Label runat="server" AssociatedControlID="txtContent" Font-Bold="True">Content *</asp:Label><br /><asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5"></asp:TextBox></asp:Panel>
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlPriority" Font-Bold="True">Priority</asp:Label><br />
                <asp:DropDownList ID="ddlPriority" runat="server">
                    <asp:ListItem>Low</asp:ListItem>
                    <asp:ListItem Selected="True">Medium</asp:ListItem>
                    <asp:ListItem>High</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
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
        </asp:Panel>
        <asp:Panel runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlStatus" Font-Bold="True">Status</asp:Label><br />
                <asp:DropDownList ID="ddlStatus" runat="server">
                    <asp:ListItem>Draft</asp:ListItem>
                    <asp:ListItem Selected="True">Published</asp:ListItem>
                    <asp:ListItem>Archived</asp:ListItem>
                </asp:DropDownList>
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="txtExpiration" Font-Bold="True">Expiration date (optional)</asp:Label><br />
                <asp:TextBox ID="txtExpiration" runat="server" TextMode="Date"></asp:TextBox>
            </asp:Panel>
            <asp:Panel runat="server">
                <label>Pin</label>
                <asp:CheckBox ID="chkPinned" runat="server" Text="Pin to top" />
            </asp:Panel>
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="fuAttachment" Font-Bold="True">Attachment (optional)</asp:Label><br />
                <asp:FileUpload ID="fuAttachment" runat="server" />
                <asp:Literal ID="litCurrentFile" runat="server"></asp:Literal>
            </asp:Panel>
        </asp:Panel>
        <asp:Button ID="btnSave" runat="server" Text="Save" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" SkinID="Secondary" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <asp:Panel runat="server" SkinID="GridArea">
        <asp:GridView ID="gvAnnouncements" runat="server" AutoGenerateColumns="False" GridLines="None" OnRowCommand="gvAnnouncements_RowCommand" EmptyDataText="No announcements yet.">
            <Columns>
                <asp:TemplateField HeaderText="Title">
                    <ItemTemplate><b><%# Ui.H(Eval("title")) %></b> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, Ui.Badge("Pinned"), "") %></ItemTemplate>
                </asp:TemplateField>
                <asp:TemplateField HeaderText="Priority">
                    <ItemTemplate><%# Ui.Badge(Eval("priority")) %></ItemTemplate>
                </asp:TemplateField>
                <asp:BoundField DataField="visibility_type" HeaderText="Visible to" />
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
                            <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this announcement?');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </asp:Panel>
</asp:Content>
