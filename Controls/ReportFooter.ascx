<%@ Control Language="VB" %>
<script runat="server">
    Public Property UsesScores As Boolean
</script>
<footer class="report-footer">
    <section>
        <h3>Scoring guide</h3>
        <% For Each line As String In ReportBuilder.ScoringGuide(UsesScores) %>
            <p><%= Ui.H(line) %></p>
        <% Next %>
    </section>
    <section class="report-signature">
        <h3>Prepared by</h3>
        <p>Signature over printed name</p>
    </section>
</footer>
