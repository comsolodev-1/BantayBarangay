Partial Class Super_Dashboard
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        PeriodHelper.EnsureScheduledPeriods()
        Dim year As Integer = DateTime.Now.Year
        Dim pending As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND s.submission_status = 'Pending'")
        Dim activeActivities As Integer = Db.ScalarInt("SELECT COUNT(*) FROM activities a WHERE a.activity_status <> 'Archived' AND " &
            "EXISTS (SELECT 1 FROM reporting_period p WHERE p.activity_id = a.activity_id AND " & PeriodHelper.AcceptsSubmissionSql & ")")
        Dim confirmed As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND s.submission_status = 'Confirmed' AND YEAR(p.submission_deadline) = @y", "@y", year)
        Dim late As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND s.is_late = 1 AND YEAR(p.submission_deadline) = @y", "@y", year)
        Dim missing As Integer = Db.ScalarInt("SELECT COUNT(*) FROM reporting_period p JOIN activity_barangays ab ON ab.activity_id = p.activity_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND " &
            PeriodHelper.CutoffSql & " < NOW() AND NOT EXISTS (SELECT 1 FROM submissions s WHERE s.period_id = p.period_id AND s.barangay_code = ab.barangay_code)")

        If pending > 0 Then litAlerts.Text = "<p><b>Action required:</b> " & pending & " submissions are waiting for review.</p>"
        Dim deadlines As Integer = PeriodHelper.PendingDeadlineCount()
        If deadlines > 0 Then
            litAlerts.Text &= "<p>" & deadlines & " recurring period(s) need a deadline. <a href=""" &
                ResolveUrl("~/Super/Activities.aspx") & """>Set reporting deadlines</a>.</p>"
        End If

        statActiveActivities.Text = Ui.H(activeActivities)
        statPending.Text = Ui.H(pending)
        statConfirmed.Text = Ui.H(confirmed)
        statConfirmedYear.Text = year.ToString()
        statLate.Text = Ui.H(late)
        statLateYear.Text = year.ToString()
        statMissing.Text = Ui.H(missing)

        gvPending.DataSource = Db.Query("SELECT b.barangay_name, a.activity_name, p.period_name, s.date_submitted, s.is_late FROM submissions s JOIN barangays b ON b.barangay_code = s.barangay_code JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND s.submission_status = 'Pending' ORDER BY s.date_submitted DESC, s.date_id DESC LIMIT 8")
        gvPending.DataBind()
        BindRanking()
    End Sub

    Private Sub BindRanking()
        gvRank.DataSource = pager.Slice(Scoring.Ranking(DateTime.Now.Year, 0))
        gvRank.DataBind()
    End Sub

    Protected Sub Pager_PageChanged(sender As Object, e As EventArgs)
        BindRanking()
    End Sub

End Class
