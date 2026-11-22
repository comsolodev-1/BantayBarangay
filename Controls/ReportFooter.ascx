<%@ Control Language="VB" %>
<script runat="server">
    Public Property UsesScores As Boolean
    Public Property UseBarangayCaptain As Boolean
</script>
<footer class="report-footer">
    <section>
        <h3>Scoring guide</h3>
        <% For Each line As String In ReportBuilder.ScoringGuide(UsesScores) %>
            <p><%= Ui.H(line) %></p>
        <% Next %>
    </section>
    <section class="report-preparer">
        <h3>Prepared by</h3>
        <% If UseBarangayCaptain Then %>
            <div class="report-preparer-line" aria-hidden="true"></div>
            <p class="report-preparer-title">BARANGAY CAPTAIN</p>
        <% Else %>
            <p class="report-preparer-name"><%= Ui.H(ReportBuilder.PreparedBy) %></p>
            <p class="report-preparer-title"><%= Ui.H(ReportBuilder.PreparedByTitle) %></p>
        <% End If %>
    </section>
</footer>
