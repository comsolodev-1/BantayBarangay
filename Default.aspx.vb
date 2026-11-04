Imports System.Data

Partial Class _Default
    Inherits PublicPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return

        Dim year As Integer = DateTime.Now.Year
        Dim barangays As Integer = Db.ScalarInt("SELECT COUNT(*) FROM barangays WHERE status = 'Active'")
        Dim activities As Integer = Db.ScalarInt("SELECT COUNT(*) FROM activities WHERE is_public = 1 AND activity_status <> 'Archived'")
        Dim confirmed As Integer = Db.ScalarInt("SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id WHERE s.submission_status = 'Confirmed' AND YEAR(p.submission_deadline) = @year", "@year", year)
        statBarangays.Text = Ui.H(barangays)
        statActivities.Text = Ui.H(activities)
        statConfirmed.Text = Ui.H(confirmed)
        statConfirmedYear.Text = year.ToString()

        Dim ranking As DataTable = Scoring.Ranking(year, 0)
        Dim top As DataTable = ranking.Clone()
        For i As Integer = 0 To Math.Min(4, ranking.Rows.Count - 1)
            top.ImportRow(ranking.Rows(i))
        Next
        gvTop.DataSource = top
        gvTop.DataBind()

        gvActivities.DataSource = Db.Query("SELECT a.activity_name, a.frequency, p.period_name, p.submission_deadline, p.period_status FROM activities a JOIN reporting_period p ON p.activity_id = a.activity_id WHERE a.is_public = 1 AND a.activity_status <> 'Archived' AND p.submission_deadline >= DATE_SUB(NOW(), INTERVAL 30 DAY) ORDER BY p.submission_deadline LIMIT 10")
        gvActivities.DataBind()

        gvDates.DataSource = Db.Query("SELECT event_date, title, event_type, location FROM important_dates WHERE visibility_type = 'All' AND event_date >= CURDATE() ORDER BY event_date LIMIT 6")
        gvDates.DataBind()
    End Sub

End Class
