<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AnnouncementsView.ascx.vb" Inherits="AnnouncementsView" %>
<asp:Repeater ID="rptAnnouncements" runat="server">
    <ItemTemplate>
        <bbui:Card runat="server" ContentPadding="16">
            <header style="border-bottom:1px solid #dce8df;padding-bottom:8px">
                <h3 style="margin:0 0 6px;color:#19462e"><%# Ui.H(Eval("title")) %></h3>
                <div>Posted <%# Ui.DateTimeText(Eval("date_published")) %>
                    <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, "<span class=""pin-label"">&#9873; Pinned</span>", "") %>
                    <%# If(Convert.ToString(Eval("priority")) = "High", Ui.Badge("High priority"), "") %>
                </div>
            </header>
            <div style="overflow-wrap:anywhere;line-height:1.5"><%# Ui.Paragraphs(Eval("content")) %></div>
            <%# If(IsDBNull(Eval("attachment_file_name")), "", "<a class=""notice-file"" href=""" & ResolveUrl("~/Download.aspx") & "?t=announcement&amp;id=" & Eval("announcement_id").ToString() & """>Download " & Ui.H(Eval("attachment_file_name")) & "</a>") %>
        </bbui:Card>
    </ItemTemplate>
</asp:Repeater>
<bbui:Card ID="emptyCard" runat="server" Visible="false"><asp:Literal ID="litEmpty" runat="server"></asp:Literal></bbui:Card>
