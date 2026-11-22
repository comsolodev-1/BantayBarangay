<%@ Control Language="VB" %>
<script runat="server">
    Public Property BarangayName As String
</script>
<div class="report-heading">
    <% If BarangayName Is Nothing Then %>
        <asp:Image runat="server" ImageUrl="~/Content/dilg-report.png" AlternateText="DILG" />
    <% Else %>
        <asp:Image runat="server" ImageUrl="~/Content/talisay-report.png" AlternateText="Municipality of Talisay" />
    <% End If %>
    <div>
        <div>Republic of the Philippines</div>
        <% If BarangayName Is Nothing Then %>
            <strong>Department of the Interior and Local Government</strong>
            <div>Municipal Operations Office</div>
        <% Else %>
            <strong><%= If(String.IsNullOrWhiteSpace(BarangayName), "Barangay Government", "Barangay " & Ui.H(BarangayName)) %></strong>
        <% End If %>
        <div>Talisay, Camarines Norte</div>
    </div>
    <asp:Image runat="server" ImageUrl="~/Content/bagong-pilipinas-report.png" AlternateText="Bagong Pilipinas" />
</div>
