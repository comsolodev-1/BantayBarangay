Imports System.Data

Partial Class Super_Reports
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        For i As Integer = 0 To ReportBuilder.Keys.GetLength(0) - 1
            ddlReport.Items.Add(New ListItem(ReportBuilder.Keys(i, 1), ReportBuilder.Keys(i, 0)))
        Next
        Ui.FillYears(ddlYear)
        Ui.FillMonths(ddlMonth)
        Ui.Fill(ddlBarangay, Db.Query("SELECT barangay_id, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_id")
        ddlBarangay.Items.Insert(0, New ListItem("All barangays", "0"))
        ShowControlsFor(ddlReport.SelectedValue)
    End Sub

    Private Sub ShowControlsFor(key As String)
        Dim isSummary As Boolean = key = "weekly" OrElse key = "monthly" OrElse key = "quarterly"
        pnlActivity.Visible = isSummary
        pnlPeriod.Visible = isSummary
        pnlBarangay.Visible = key = "roster" OrElse key = "reportcard"
        pnlYear.Visible = key = "ranking" OrElse key = "calendar" OrElse key = "announcements" OrElse key = "late" OrElse key = "nonsubmission" OrElse key = "reportcard"
        pnlMonth.Visible = key = "ranking" OrElse key = "calendar" OrElse key = "announcements" OrElse key = "late" OrElse key = "nonsubmission"
        If key = "reportcard" AndAlso ddlBarangay.Items.Count > 0 AndAlso ddlBarangay.Items(0).Value = "0" Then
            ddlBarangay.Items.RemoveAt(0)
        ElseIf key = "roster" AndAlso ddlBarangay.Items.Count > 0 AndAlso ddlBarangay.Items(0).Value <> "0" Then
            ddlBarangay.Items.Insert(0, New ListItem("All barangays", "0"))
        End If
        If key = "ranking" AndAlso ddlMonth.Items(0).Value <> "0" Then
            ddlMonth.Items.Insert(0, New ListItem("All months", "0"))
        ElseIf key <> "ranking" AndAlso ddlMonth.Items(0).Value = "0" Then
            ddlMonth.Items.RemoveAt(0)
        End If
        If isSummary Then
            Dim frequency As String = If(key = "weekly", "Weekly", If(key = "monthly", "Monthly", "Quarterly"))
            Ui.Fill(ddlActivity, Db.Query("SELECT activity_id, activity_name FROM activities WHERE frequency = @f AND activity_status <> 'Archived' ORDER BY activity_name", "@f", frequency), "activity_name", "activity_id")
            BindPeriods()
        End If
    End Sub

    Private Sub BindPeriods()
        ddlPeriod.Items.Clear()
        If ddlActivity.Items.Count = 0 Then Return
        Ui.Fill(ddlPeriod, Db.Query("SELECT period_id, period_name FROM reporting_period WHERE activity_id = @a ORDER BY submission_deadline DESC", "@a", CInt(ddlActivity.SelectedValue)), "period_name", "period_id")
    End Sub

    Protected Sub ddlReport_SelectedIndexChanged(sender As Object, e As EventArgs)
        pnlResult.Visible = False
        ShowControlsFor(ddlReport.SelectedValue)
    End Sub

    Protected Sub ddlActivity_SelectedIndexChanged(sender As Object, e As EventArgs)
        BindPeriods()
    End Sub

    Private Function BuildReport() As ReportResult
        Dim year As Integer = CInt(ddlYear.SelectedValue)
        Dim month As Integer = CInt(ddlMonth.SelectedValue)
        Select Case ddlReport.SelectedValue
            Case "weekly", "monthly", "quarterly"
                If ddlPeriod.Items.Count = 0 Then Return Nothing
                Dim label As String = If(ddlReport.SelectedValue = "weekly", "Weekly", If(ddlReport.SelectedValue = "monthly", "Monthly", "Quarterly"))
                Return ReportBuilder.ActivitySummary(CInt(ddlPeriod.SelectedValue), label)
            Case "ranking"
                Return ReportBuilder.Ranking(year, month)
            Case "roster"
                Return ReportBuilder.Roster(CInt(ddlBarangay.SelectedValue))
            Case "calendar"
                Return ReportBuilder.MonthlyCalendar(year, month)
            Case "announcements"
                Return ReportBuilder.Announcements(year, month)
            Case "late"
                Return ReportBuilder.LateSubmissions(year, month)
            Case "nonsubmission"
                Return ReportBuilder.NonSubmission(year, month)
            Case "reportcard"
                If ddlBarangay.Items.Count = 0 Then Return Nothing
                Return ReportBuilder.ReportCard(CInt(ddlBarangay.SelectedValue), year)
        End Select
        Return Nothing
    End Function

    Protected Sub btnPreview_Click(sender As Object, e As EventArgs)
        Dim report As ReportResult = BuildReport()
        If report Is Nothing Then
            Ui.Notice(litMessage, "Choose an activity and period first. Create an activity with that frequency if none is listed.", False)
            pnlResult.Visible = False
            Return
        End If
        litTitle.Text = Ui.H(report.Title)
        litSubtitle.Text = Ui.H(report.Subtitle)
        Dim notes As String = ""
        For Each note As String In report.Notes
            notes &= "<p>" & Ui.H(note) & "</p>"
        Next
        litNotes.Text = notes
        gvPreview.DataSource = report.Table
        gvPreview.DataBind()
        pnlResult.Visible = True
    End Sub

    Protected Sub btnPdf_Click(sender As Object, e As EventArgs)
        Dim report As ReportResult = BuildReport()
        If report Is Nothing Then
            Ui.Notice(litMessage, "Choose an activity and period first. Create an activity with that frequency if none is listed.", False)
            Return
        End If
        PdfExport.Send(Response, report, ddlReport.SelectedValue & "-report.pdf")
    End Sub

End Class
