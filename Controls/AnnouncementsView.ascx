<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AnnouncementsView.ascx.vb" Inherits="AnnouncementsView" %>
<asp:Repeater ID="rptAnnouncements" runat="server">
    <ItemTemplate>
        <article class='notice-card <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, "pinned", "") %>'>
            <header><h3><%# Ui.H(Eval("title")) %></h3>
                <div class="notice-meta">Posted <%# Ui.DateTimeText(Eval("date_published")) %>
                    <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, "<span class=""pin-label"">&#9873; Pinned</span>", "") %>
                    <%# If(Convert.ToString(Eval("priority")) = "High", Ui.Badge("High priority"), "") %>
                </div>
            </header>
            <div class="notice-body"><%# Ui.Paragraphs(Eval("content")) %></div>
            <%# If(IsDBNull(Eval("attachment_file_name")), "", "<a class=""notice-file"" href=""" & ResolveUrl("~/Download.aspx") & "?t=announcement&amp;id=" & Eval("announcement_id").ToString() & """>Download " & Ui.H(Eval("attachment_file_name")) & "</a>") %>
        </article>
    </ItemTemplate>
</asp:Repeater>
<bbui:Card ID="emptyCard" runat="server" Visible="false"><asp:Literal ID="litEmpty" runat="server"></asp:Literal></bbui:Card>
