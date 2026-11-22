Imports System.Data
Imports System.Globalization

Partial Class Super_Submissions
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Dim barangays As DataTable = Db.Query("SELECT barangay_code, barangay_name FROM barangays ORDER BY barangay_name")
        Ui.Fill(ddlBarangay, barangays, "barangay_name", "barangay_code")
        ddlBarangay.Items.Insert(0, New ListItem("All barangays", ""))
        BindGrid()
    End Sub

    Private Sub BindGrid()
        litDateMessage.Text = ""
        Dim fromDay As DateTime
        Dim throughDay As DateTime
        Dim hasFrom As Boolean = txtSubmittedFrom.Text <> ""
        Dim hasThrough As Boolean = txtSubmittedTo.Text <> ""
        If (hasFrom AndAlso Not DateTime.TryParseExact(txtSubmittedFrom.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, fromDay)) OrElse
            (hasThrough AndAlso Not DateTime.TryParseExact(txtSubmittedTo.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, throughDay)) Then
            Ui.Notice(litDateMessage, "Choose a valid submission date.", False)
            Return
        End If
        If hasFrom AndAlso hasThrough AndAlso fromDay > throughDay Then
            Ui.Notice(litDateMessage, "Submitted through must be on or after Submitted from.", False)
            Return
        End If

        Dim sql As String = "SELECT s.date_id, b.barangay_name, a.activity_name, p.period_name, s.date_submitted, s.is_late, s.file_name, s.submission_status, s.score, s.remarks, s.denial_reason " &
            "FROM submissions s JOIN barangays b ON b.barangay_code = s.barangay_code JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id " &
            "WHERE a.activity_status <> 'Archived' AND a.activity_name LIKE @search AND (@status = '' OR s.submission_status = @status) AND (@barangay = '' OR s.barangay_code = @barangay) " &
            "AND (@fromDay IS NULL OR s.date_submitted >= @fromDay) AND (@throughDay IS NULL OR s.date_submitted <= @throughDay) "
        sql &= If(ddlDateOrder.SelectedValue = "asc", "ORDER BY s.date_submitted ASC, s.date_id ASC", "ORDER BY s.date_submitted DESC, s.date_id DESC")
        gvSubmissions.DataSource = Db.Query(sql, "@search", "%" & txtSearch.Text.Trim() & "%", "@status", ddlStatus.SelectedValue, "@barangay", ddlBarangay.SelectedValue,
                                            "@fromDay", If(hasFrom, CObj(fromDay), Nothing), "@throughDay", If(hasThrough, CObj(PeriodHelper.EndOfDay(throughDay)), Nothing))
        gvSubmissions.DataBind()
    End Sub

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        BindGrid()
    End Sub

    Protected Sub gvSubmissions_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName <> "ReviewRow" Then Return
        Dim submissionId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), submissionId) Then Return
        Dim row As DataRow = Db.QueryRow("SELECT s.date_id, b.barangay_name, a.activity_name, p.period_name, p.submission_deadline, s.date_submitted, s.is_late, s.file_name FROM submissions s JOIN barangays b ON b.barangay_code = s.barangay_code JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE s.date_id = @id AND s.submission_status = 'Pending' AND a.activity_status <> 'Archived'", "@id", submissionId)
        If row Is Nothing Then Return
        hfSubmissionId.Value = submissionId.ToString()
        Dim late As Boolean = Convert.ToInt32(row("is_late")) = 1
        litReviewInfo.Text = "<section class=""detail-summary""><h3>Assignment</h3><dl><dt>Barangay</dt><dd>" & Ui.H(row("barangay_name")) & "</dd><dt>Activity</dt><dd>" & Ui.H(row("activity_name")) & " (" & Ui.H(row("period_name")) & ")</dd></dl></section>" &
            "<section class=""detail-section""><h3>Submission</h3>Deadline: " & Ui.DateTimeText(row("submission_deadline")) & " &nbsp; Submitted: " & Ui.DateTimeText(row("date_submitted")) & If(late, " " & Ui.Badge("Late"), "") & "<br />" &
            "File: <a href=""" & ResolveUrl("~/Download.aspx") & "?t=submission&amp;id=" & submissionId & """>" & Ui.H(row("file_name")) & "</a><br />" &
            "</section><section class=""detail-section""><h3>Score if confirmed</h3>" & Ui.ScoreText(Scoring.ScoreFor(late)) & "</section>"
        txtReason.Text = ""
        pnlReview.Visible = True
    End Sub

    Private Function ReadReason(required As Boolean, ByRef reason As String) As Boolean
        reason = txtReason.Text.Trim()
        If required AndAlso reason.Length = 0 Then
            Ui.Notice(litMessage, "Please enter a reason for denying the submission.", False)
            Return False
        End If
        If reason.Length > txtReason.MaxLength Then
            Ui.Notice(litMessage, "The reason must be 255 characters or fewer.", False)
            Return False
        End If
        Return True
    End Function

    Protected Sub btnConfirm_Click(sender As Object, e As EventArgs)
        Dim submissionId As Integer = CInt(hfSubmissionId.Value)
        Dim reason As String = Nothing
        If Not ReadReason(False, reason) Then Return
        Dim changed As Integer = Db.Execute(
            "UPDATE submissions s JOIN reporting_period p ON p.period_id = s.period_id " &
            "JOIN activities a ON a.activity_id = p.activity_id " &
            "SET s.submission_status = 'Confirmed', s.score = IF(s.is_late = 1, @lateScore, @onTimeScore), " &
            "s.confirmed_by = @user, s.confirmation_date = NOW(), s.remarks = @remark, " &
            "s.denial_reason = @reason, s.date_modified = NOW() " &
            "WHERE s.date_id = @id AND s.submission_status = 'Pending' AND a.activity_status <> 'Archived'",
            "@lateScore", Scoring.LateScore, "@onTimeScore", Scoring.OnTimeScore,
            "@user", Auth.UserId, "@remark", ddlRemark.SelectedValue, "@reason", If(reason.Length = 0, Nothing, reason), "@id", submissionId)
        pnlReview.Visible = False
        Ui.Notice(litMessage, If(changed > 0, "Submission confirmed.", "This submission is no longer awaiting review."), changed > 0)
        BindGrid()
    End Sub

    Protected Sub btnDeny_Click(sender As Object, e As EventArgs)
        Dim submissionId As Integer = CInt(hfSubmissionId.Value)
        Dim reason As String = Nothing
        If Not ReadReason(True, reason) Then Return
        Dim attachmentPath As String = Nothing
        If fuDenial.HasFile Then
            Dim attachmentName As String = ""
            Dim errorMessage As String = ""
            If Not Uploads.Save(fuDenial, "denials", attachmentPath, attachmentName, errorMessage) Then
                Ui.Notice(litMessage, errorMessage, False)
                Return
            End If
        End If
        Dim changed As Integer = Db.Execute("UPDATE submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id SET s.submission_status = 'Denied', s.score = NULL, s.confirmed_by = @user, s.confirmation_date = NOW(), s.remarks = NULL, s.denial_reason = @reason, s.denial_attachment = @attachment, s.date_modified = NOW() WHERE s.date_id = @id AND s.submission_status = 'Pending' AND a.activity_status <> 'Archived'",
                                            "@user", Auth.UserId, "@reason", reason, "@attachment", attachmentPath, "@id", submissionId)
        If changed = 0 Then Uploads.Delete(attachmentPath)
        pnlReview.Visible = False
        Ui.Notice(litMessage, If(changed > 0, "Submission denied. The barangay can now resubmit.", "This submission is no longer awaiting review."), changed > 0)
        BindGrid()
    End Sub

    Protected Sub btnCancelReview_Click(sender As Object, e As EventArgs)
        pnlReview.Visible = False
    End Sub

End Class
