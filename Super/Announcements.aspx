<%@ Page Title="Announcements" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Announcements.aspx.vb" Inherits="Super_Announcements" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <div class="panel-title">
        <div>
            <h1>Announcements</h1>
            <p class="sub">Post notices for the public, a role, or a specific barangay.</p>
        </div>
        <asp:Button ID="btnNew" runat="server" Text="+ New Announcement" CssClass="btn" CausesValidation="false" OnClick="btnNew_Click" />
    </div>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>

    <asp:Panel ID="pnlForm" runat="server" Visible="false" CssClass="card">
        <h2><asp:Literal ID="litFormTitle" runat="server"></asp:Literal></h2>
        <asp:HiddenField ID="hfId" runat="server" Value="0" />
        <div class="row">
            <div class="field wide"><label>Title *</label><asp:TextBox ID="txtTitle" runat="server" MaxLength="150"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field wide"><label>Content *</label><asp:TextBox ID="txtContent" runat="server" TextMode="MultiLine" Rows="5"></asp:TextBox></div>
        </div>
        <div class="row">
            <div class="field">
                <label>Priority</label>
                <asp:DropDownList ID="ddlPriority" runat="server">
                    <asp:ListItem>Low</asp:ListItem>
                    <asp:ListItem Selected="True">Medium</asp:ListItem>
                    <asp:ListItem>High</asp:ListItem>
                </asp:DropDownList>
            </div>
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
        </div>
        <div class="row">
            <div class="field">
                <label>Status</label>
                <asp:DropDownList ID="ddlStatus" runat="server">
                    <asp:ListItem>Draft</asp:ListItem>
                    <asp:ListItem Selected="True">Published</asp:ListItem>
                    <asp:ListItem>Archived</asp:ListItem>
                </asp:DropDownList>
            </div>
            <div class="field">
                <label>Expiration date (optional)</label>
                <asp:TextBox ID="txtExpiration" runat="server" TextMode="Date"></asp:TextBox>
            </div>
            <div class="field">
                <label>Pin</label>
                <asp:CheckBox ID="chkPinned" runat="server" Text="Pin to top" />
            </div>
            <div class="field wide">
                <label>Attachment (optional)</label>
                <asp:FileUpload ID="fuAttachment" runat="server" />
                <asp:Literal ID="litCurrentFile" runat="server"></asp:Literal>
            </div>
        </div>
        <asp:Button ID="btnSave" runat="server" Text="Save" CssClass="btn" OnClick="btnSave_Click" />
        <asp:Button ID="btnCancel" runat="server" Text="Cancel" CssClass="btn btn-outline" CausesValidation="false" OnClick="btnCancel_Click" />
    </asp:Panel>

    <div class="grid-wrap">
        <asp:GridView ID="gvAnnouncements" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" OnRowCommand="gvAnnouncements_RowCommand" EmptyDataText="No announcements yet.">
            <Columns>
                <asp:TemplateField HeaderText="Title">
                    <ItemTemplate><b><%# Ui.H(Eval("title")) %></b> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, "<span class=""badge badge-medium"">Pinned</span>", "") %></ItemTemplate>
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
                        <span class="actions">
                            <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                            <asp:LinkButton runat="server" CssClass="danger" CommandName="DeleteRow" CommandArgument='<%# Eval("announcement_id") %>' CausesValidation="false" OnClientClick="return confirm('Delete this announcement?');">Delete</asp:LinkButton>
                        </span>
                    </ItemTemplate>
                </asp:TemplateField>
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
