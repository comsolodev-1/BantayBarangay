<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AnnouncementsView.ascx.vb" Inherits="AnnouncementsView" %>
<asp:Repeater ID="rptAnnouncements" runat="server">
    <ItemTemplate>
        <bbui:Card runat="server">
            <p><asp:Label runat="server" Font-Size="11pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="3"><%# Ui.H(Eval("title")) %> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, Ui.Badge("Pinned"), "") %> <%# If(Not IsDBNull(Eval("priority")) AndAlso Convert.ToString(Eval("priority")) = "High", Ui.Badge("High"), "") %></asp:Label></p>
            <small>Posted <%# Ui.DateTimeText(Eval("date_published")) %></small>
            <p><%# Ui.H(Eval("content")).Replace(vbLf, "<br />") %></p>
            <%# If(IsDBNull(Eval("attachment_file_name")), "", "<a href=""" & ResolveUrl("~/Download.aspx") & "?t=announcement&amp;id=" & Eval("announcement_id").ToString() & """>Download: " & Ui.H(Eval("attachment_file_name")) & "</a>") %>
        </bbui:Card>
    </ItemTemplate>
</asp:Repeater>
<asp:Literal ID="litEmpty" runat="server"></asp:Literal>
