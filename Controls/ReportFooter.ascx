<%@ Control Language="VB" %>
<script runat="server">
    Public Property UsesScores As Boolean
</script>
<footer style="margin-top:16px">
    <section>
        <h3>Scoring guide</h3>
        <% For Each line As String In ReportBuilder.ScoringGuide(UsesScores) %>
            <p><%= Ui.H(line) %></p>
        <% Next %>
    </section>
    <section style="margin-top:24px">
        <h3>Prepared by</h3>
        <strong><u><%= Ui.H(ReportBuilder.PreparedBy) %></u></strong><br />
        <strong><%= Ui.H(ReportBuilder.PreparedByTitle) %></strong>
    </section>
</footer>
