Imports System.Data

Partial Class Barangay_MyReports
    Inherits BarangayPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.FillYears(ddlYear)
        BindHistory()
    End Sub

    Private Sub BindHistory()
        gvHistory.DataSource = ReadHistory()
        gvHistory.DataBind()
        If gvHistory.HeaderRow IsNot Nothing Then gvHistory.HeaderRow.TableSection = TableRowSection.TableHeader
    End Sub

    Private Function ReadHistory() As DataTable
        Return Db.Query("SELECT s.date_id, a.activity_name, p.period_name, s.date_submitted, s.file_name, s.submission_status, s.is_late, s.score, s.remarks, s.denial_reason FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE a.activity_status <> 'Archived' AND s.barangay_code = @b AND YEAR(p.submission_deadline) = @y ORDER BY s.date_submitted DESC", "@b", Auth.BarangayCode, "@y", CInt(ddlYear.SelectedValue))
    End Function

    ' Print submission history. Open the same filtered rows as a print-ready PDF.
    Protected Sub btnPrintHistory_Click(sender As Object, e As EventArgs)
        Dim report As New ReportResult With {
            .Title = "Barangay Submission History",
            .Subtitle = Auth.BarangayName & " " & ddlYear.SelectedValue,
            .Summary = "This report lists submissions filed by the barangay for reporting periods in the selected year.",
            .BarangayHeading = If(Auth.BarangayName, ""),
            .UsesScores = True,
            .Table = New DataTable()
        }
        For Each heading As String In {"Activity", "Period", "Submitted", "File", "Status", "Score", "Remarks / Reason"}
            report.Table.Columns.Add(heading)
        Next
        For Each row As DataRow In ReadHistory().Rows
            Dim submitted As String = Ui.DateTimeText(row("date_submitted"))
            If CInt(row("is_late")) = 1 Then submitted &= " (Late)"
            report.Table.Rows.Add(row("activity_name"), row("period_name"), submitted, row("file_name"),
                                  row("submission_status"), Ui.ScoreText(row("score")),
                                  (Convert.ToString(row("remarks")) & " " & Convert.ToString(row("denial_reason"))).Trim())
        Next
        PdfExport.Send(Response, report, "submission-history-" & ddlYear.SelectedValue & ".pdf", openInBrowser:=True)
    End Sub

    Protected Sub ddlYear_SelectedIndexChanged(sender As Object, e As EventArgs)
        BindHistory()
    End Sub

    Protected Sub btnReportCard_Click(sender As Object, e As EventArgs)
        Dim report As ReportResult = ReportBuilder.ReportCard(Auth.BarangayCode, CInt(ddlYear.SelectedValue))
        PdfExport.Send(Response, report, "report-card-" & ddlYear.SelectedValue & ".pdf", ReportBuilder.MinimumPrintRows)
    End Sub

End Class
