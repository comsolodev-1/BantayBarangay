Partial Class Super_Dashboard
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Dim year As Integer = DateTime.Now.Year
        Dim pending As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions WHERE submission_status = 'Pending'")
        Dim activeActivities As Integer = Db.ScalarInt("SELECT COUNT(*) FROM activities WHERE activity_status = 'Active'")
        Dim confirmed As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id WHERE s.submission_status = 'Confirmed' AND YEAR(p.submission_deadline) = @y", "@y", year)
        Dim late As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id WHERE s.is_late = 1 AND YEAR(p.submission_deadline) = @y", "@y", year)
        Dim missing As Integer = Db.ScalarInt("SELECT COUNT(*) FROM reporting_period p JOIN activity_barangays ab ON ab.activity_id = p.activity_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND p.submission_deadline < NOW() AND NOT EXISTS (SELECT 1 FROM submissions s WHERE s.period_id = p.period_id AND s.barangay_id = ab.barangay_id)")

        If pending > 0 Then litAlerts.Text = "<p><b>Action required:</b> " & pending & " submissions are waiting for review.</p>"

        statActiveActivities.Text = Ui.H(activeActivities)
        statPending.Text = Ui.H(pending)
        statConfirmed.Text = Ui.H(confirmed)
        statConfirmedYear.Text = year.ToString()
        statLate.Text = Ui.H(late)
        statLateYear.Text = year.ToString()
        statMissing.Text = Ui.H(missing)

        gvPending.DataSource = Db.Query("SELECT b.barangay_name, a.activity_name, p.period_name, s.date_submitted, s.is_late FROM submissions s JOIN barangays b ON b.barangay_id = s.barangay_id JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE s.submission_status = 'Pending' ORDER BY s.date_submitted LIMIT 8")
        gvPending.DataBind()
        gvRank.DataSource = Scoring.Ranking(year, 0)
        gvRank.DataBind()
    End Sub

End Class
