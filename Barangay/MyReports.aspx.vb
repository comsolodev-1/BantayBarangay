Partial Class Barangay_MyReports
    Inherits BarangayPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.FillYears(ddlYear)
        BindHistory()
    End Sub

    Private Sub BindHistory()
        gvHistory.DataSource = Db.Query("SELECT s.date_id, a.activity_name, p.period_name, s.date_submitted, s.file_name, s.submission_status, s.is_late, s.score, s.remarks, s.denial_reason FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE s.barangay_id = @b AND YEAR(p.submission_deadline) = @y ORDER BY s.date_submitted DESC", "@b", Auth.BarangayId, "@y", CInt(ddlYear.SelectedValue))
        gvHistory.DataBind()
    End Sub

    Protected Sub ddlYear_SelectedIndexChanged(sender As Object, e As EventArgs)
        BindHistory()
    End Sub

    Protected Sub btnReportCard_Click(sender As Object, e As EventArgs)
        Dim report As ReportResult = ReportBuilder.ReportCard(Auth.BarangayId, CInt(ddlYear.SelectedValue))
        PdfExport.Send(Response, report, "report-card-" & ddlYear.SelectedValue & ".pdf")
    End Sub

End Class
