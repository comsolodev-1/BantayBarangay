<%@ Control Language="VB" AutoEventWireup="false" CodeFile="AnnouncementsView.ascx.vb" Inherits="AnnouncementsView" %>
<asp:Repeater ID="rptAnnouncements" runat="server">
    <ItemTemplate>
        <div class="card ann <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, "pinned", "") %>">
            <h3><%# Ui.H(Eval("title")) %> <%# If(Convert.ToInt32(Eval("is_pinned")) = 1, "<span class=""badge badge-medium"">Pinned</span>", "") %> <%# If(Not IsDBNull(Eval("priority")) AndAlso Convert.ToString(Eval("priority")) = "High", Ui.Badge("High"), "") %></h3>
            <small>Posted <%# Ui.DateTimeText(Eval("date_published")) %></small>
            <p><%# Ui.H(Eval("content")).Replace(vbLf, "<br />") %></p>
            <%# If(IsDBNull(Eval("attachment_file_name")), "", "<a class=""btn btn-outline btn-sm"" href=""" & ResolveUrl("~/Download.aspx") & "?t=announcement&amp;id=" & Eval("announcement_id").ToString() & """>Download: " & Ui.H(Eval("attachment_file_name")) & "</a>") %>
        </div>
    </ItemTemplate>
</asp:Repeater>
<asp:Literal ID="litEmpty" runat="server"></asp:Literal>
