<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AnnouncementsView.ascx.vb" Inherits="AnnouncementsView" %>
<asp:Repeater ID="rptAnnouncements" runat="server">
    <ItemTemplate>
        <asp:Table runat="server" SkinID="Section" role="presentation"><asp:TableRow><asp:TableCell>
            <h3><%# Ui.H(Eval("title")) %> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, Ui.Badge("Pinned"), "") %> <%# If(Not IsDBNull(Eval("priority")) AndAlso Convert.ToString(Eval("priority")) = "High", Ui.Badge("High"), "") %></h3>
            <small>Posted <%# Ui.DateTimeText(Eval("date_published")) %></small>
            <p><%# Ui.H(Eval("content")).Replace(vbLf, "<br />") %></p>
            <%# If(IsDBNull(Eval("attachment_file_name")), "", "<a href=""" & ResolveUrl("~/Download.aspx") & "?t=announcement&amp;id=" & Eval("announcement_id").ToString() & """>Download: " & Ui.H(Eval("attachment_file_name")) & "</a>") %>
        </asp:TableCell></asp:TableRow></asp:Table>
    </ItemTemplate>
</asp:Repeater>
<asp:Literal ID="litEmpty" runat="server"></asp:Literal>
