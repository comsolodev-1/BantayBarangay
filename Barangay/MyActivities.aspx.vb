Imports System.Data

Partial Class Barangay_MyActivities
    Inherits BarangayPage

    Private Property SelectedPeriodId As Integer
        Get
            Dim value As Object = ViewState("SelectedPeriodId")
            If value Is Nothing Then Return 0
            Return CInt(value)
        End Get
        Set(value As Integer)
            ViewState("SelectedPeriodId") = value
        End Set
    End Property

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then BindGrid()
    End Sub

    Private Sub BindGrid()
        Dim data As DataTable = Assignments.ForBarangay(Auth.BarangayCode)
        Dim filtered As DataTable = data.Clone()
        Dim search As String = txtSearch.Text.Trim()
        For Each row As DataRow In data.Rows
            If search.Length > 0 AndAlso CStr(row("activity_name")).IndexOf(search, StringComparison.OrdinalIgnoreCase) < 0 Then Continue For
            If ddlStatus.SelectedValue.Length > 0 AndAlso CStr(row("display_status")) <> ddlStatus.SelectedValue Then Continue For
            filtered.ImportRow(row)
        Next
        gvActivities.DataSource = filtered
        gvActivities.DataBind()
    End Sub

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        BindGrid()
    End Sub

    Private Shared Function TextBlock(label As String, value As Object) As String
        If value Is Nothing OrElse IsDBNull(value) OrElse Convert.ToString(value).Length = 0 Then Return ""
        Return "<section class=""detail-section""><h3>" & Ui.H(label) & "</h3>" & Ui.Paragraphs(value) & "</section>"
    End Function

    Private Sub ShowDetails(row As DataRow)
        Dim html As String = "<header class=""detail-summary""><h3>" & Ui.H(row("activity_name")) & "</h3><span class=""activity-status"">" & Ui.H(row("display_status")) &
            "</span><dl><dt>Reporting period</dt><dd>" & Ui.H(row("period_name")) & "</dd><dt>Deadline</dt><dd>" & Ui.DateTimeText(row("submission_deadline")) &
            "</dd><dt>Cut-off</dt><dd>" & Ui.DateTimeText(row("cutoff")) & "</dd><dt>Period status</dt><dd>" & Ui.H(row("period_status")) & "</dd></dl></header>"
        html &= TextBlock("Description", row("description"))
        html &= TextBlock("Requirements / Instructions", row("instructions"))
        If Not IsDBNull(row("template_file_name")) Then
            html &= "<section class=""detail-section""><h3>Attachment</h3><a class=""notice-file"" href=""" & ResolveUrl("~/Download.aspx") & "?t=template&amp;id=" & row("activity_id").ToString() & """>Download template: " & Ui.H(row("template_file_name")) & "</a></section>"
        End If
        If Not IsDBNull(row("submission_id")) Then
            html &= TextBlock("Remarks", row("remarks"))
            html &= TextBlock("Reason", row("denial_reason"))
            If Not IsDBNull(row("denial_attachment")) Then
                html &= "<p><a href=""" & ResolveUrl("~/Download.aspx") & "?t=denial&amp;id=" & row("submission_id").ToString() & """>Download denial attachment</a></p>"
            End If
            html &= "<small>Submitted " & Ui.DateTimeText(row("date_submitted")) & If(Convert.ToInt32(row("is_late")) = 1, " (late)", "") & "</small>"
        End If
        SelectedPeriodId = CInt(row("period_id"))
        btnDetailsSubmit.Visible = Assignments.CanSubmit(row("accepting"), row("display_status"))
        litDetails.Text = html
        pnlDetails.Visible = True
        pnlSubmit.Visible = False
    End Sub

    Protected Sub gvActivities_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim periodId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), periodId) Then Return
        Dim row As DataRow = Assignments.PeriodForBarangay(periodId, Auth.BarangayCode)
        If row Is Nothing Then Return
        Select Case e.CommandName
            Case "ShowDetails"
                ShowDetails(row)
            Case "StartSubmit"
                If Assignments.CanSubmit(row("accepting"), row("display_status")) Then
                    OpenSubmission(row, periodId)
                Else
                    Ui.Notice(litMessage, "This period is no longer accepting this submission.", False)
                End If
        End Select
        BindGrid()
    End Sub

    Private Sub OpenSubmission(row As DataRow, periodId As Integer)
        SelectedPeriodId = periodId
        litSubmitInfo.Text = "<section class=""detail-summary""><h3>" & Ui.H(row("activity_name")) & " - " & Ui.H(row("period_name")) & "</h3>"
        Dim deadline = Ui.DateTimeText(row("submission_deadline"))
        If CStr(row("period_status")) = "Grace Period" Then
            litSubmitInfo.Text &= "<aside class=""late-notice""><b>GRACE PERIOD</b> - Deadline: " & deadline & "<br /><strong>This report will be marked late (0.5 point if confirmed).</strong></aside>"
        Else
            litSubmitInfo.Text &= "<p>Deadline: " & deadline & "</p>"
        End If
        litSubmitInfo.Text &= "<p>Submission cut-off: " & Ui.DateTimeText(row("cutoff")) & "</p></section>"
        pnlSubmit.Visible = True
        pnlDetails.Visible = False
    End Sub

    Protected Sub btnDetailsSubmit_Click(sender As Object, e As EventArgs)
        Dim row = Assignments.PeriodForBarangay(SelectedPeriodId, Auth.BarangayCode)
        If row IsNot Nothing AndAlso Assignments.CanSubmit(row("accepting"), row("display_status")) Then
            OpenSubmission(row, SelectedPeriodId)
        Else
            Ui.Notice(litMessage, "This period is no longer accepting this submission.", False)
        End If
    End Sub

    Protected Sub btnConfirmSubmit_Click(sender As Object, e As EventArgs)
        Dim row As DataRow = Assignments.PeriodForBarangay(SelectedPeriodId, Auth.BarangayCode)
        If row Is Nothing Then
            Ui.Notice(litMessage, "This activity is not assigned to your barangay.", False)
            pnlSubmit.Visible = False
            Return
        End If
        If Not Assignments.CanSubmit(row("accepting"), row("display_status")) Then
            Ui.Notice(litMessage, "This period is no longer accepting this submission. Check the cut-off and current status.", False)
            pnlSubmit.Visible = False
            BindGrid()
            Return
        End If

        Dim storedPath As String = ""
        Dim originalName As String = ""
        Dim errorMessage As String = ""
        If Not Uploads.Save(fuReport, "submissions", storedPath, originalName, errorMessage) Then
            Ui.Notice(litMessage, errorMessage, False)
            Return
        End If

        Try
            If IsDBNull(row("submission_id")) Then
                Dim added As Integer = Db.Execute(
                    "INSERT INTO submissions (period_id, barangay_code, submitted_by, file_name, file_path, date_submitted, submission_status, submission_type, is_late) " &
                    "SELECT p.period_id, @barangay, @user, @fileName, @filePath, NOW(), 'Pending', 'Regular', NOW() > p.submission_deadline " &
                    "FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
                    "JOIN activity_barangays ab ON ab.activity_id = a.activity_id AND ab.barangay_code = @barangay " &
                    "WHERE p.period_id = @period AND a.activity_status <> 'Archived' AND " & PeriodHelper.AcceptsSubmissionSql,
                    "@period", SelectedPeriodId, "@barangay", Auth.BarangayCode, "@user", Auth.UserId,
                    "@fileName", originalName, "@filePath", storedPath)
                If added = 0 Then
                    Uploads.Delete(storedPath)
                    pnlSubmit.Visible = False
                    Ui.Notice(litMessage, "This period is no longer accepting submissions.", False)
                    BindGrid()
                    Return
                End If
            Else
                Dim old As DataRow = Db.QueryRow("SELECT file_path, denial_attachment FROM submissions WHERE date_id = @id AND barangay_code = @b AND submission_status = 'Denied'", "@id", CInt(row("submission_id")), "@b", Auth.BarangayCode)
                If old Is Nothing Then
                    Uploads.Delete(storedPath)
                    Ui.Notice(litMessage, "This submission can no longer be replaced.", False)
                    Return
                End If
                Dim changed As Integer = Db.Execute("UPDATE submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id JOIN activity_barangays ab ON ab.activity_id = a.activity_id AND ab.barangay_code = s.barangay_code SET s.file_name = @fileName, s.file_path = @filePath, s.submitted_by = @user, s.date_submitted = NOW(), s.submission_status = 'Pending', s.submission_type = 'Resubmission', s.is_late = NOW() > p.submission_deadline, s.score = NULL, s.confirmed_by = NULL, s.confirmation_date = NULL, s.remarks = NULL, s.denial_reason = NULL, s.denial_attachment = NULL, s.resubmission_count = s.resubmission_count + 1, s.date_modified = NOW() WHERE s.date_id = @id AND s.barangay_code = @b AND s.submission_status = 'Denied' AND s.file_path = @previousPath AND a.activity_status <> 'Archived' AND " & PeriodHelper.AcceptsSubmissionSql,
                           "@fileName", originalName, "@filePath", storedPath, "@user", Auth.UserId, "@id", CInt(row("submission_id")), "@b", Auth.BarangayCode, "@previousPath", CStr(old("file_path")))
                If changed = 0 Then
                    Uploads.Delete(storedPath)
                    pnlSubmit.Visible = False
                    Ui.Notice(litMessage, "The submission changed or its cut-off passed. Check its current status.", False)
                    BindGrid()
                    Return
                End If
                Uploads.Delete(CStr(old("file_path")))
                If Not IsDBNull(old("denial_attachment")) Then Uploads.Delete(CStr(old("denial_attachment")))
            End If
        Catch
            Uploads.Delete(storedPath)
            Ui.Notice(litMessage, "The report could not be saved. Please try again.", False)
            Return
        End Try

        pnlSubmit.Visible = False
        Ui.Notice(litMessage, "Report submitted. It is now waiting for review.", True)
        BindGrid()
    End Sub

    Protected Sub btnCancelSubmit_Click(sender As Object, e As EventArgs)
        pnlSubmit.Visible = False
    End Sub

    Protected Sub btnCloseDetails_Click(sender As Object, e As EventArgs)
        pnlDetails.Visible = False
    End Sub

End Class
