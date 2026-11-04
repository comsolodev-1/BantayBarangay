Imports System.Data

Partial Class Super_Submissions
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Dim barangays As DataTable = Db.Query("SELECT barangay_id, barangay_name FROM barangays ORDER BY barangay_name")
        Ui.Fill(ddlBarangay, barangays, "barangay_name", "barangay_id")
        ddlBarangay.Items.Insert(0, New ListItem("All barangays", "0"))
        BindGrid()
    End Sub

    Private Sub BindGrid()
        Dim sql As String = "SELECT s.date_id, b.barangay_name, a.activity_name, p.period_name, s.date_submitted, s.is_late, s.file_name, s.submission_status, s.score, s.remarks, s.denial_reason " &
            "FROM submissions s JOIN barangays b ON b.barangay_id = s.barangay_id JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id " &
            "WHERE a.activity_name LIKE @search AND (@status = '' OR s.submission_status = @status) AND (@barangay = 0 OR s.barangay_id = @barangay) ORDER BY s.date_submitted DESC"
        gvSubmissions.DataSource = Db.Query(sql, "@search", "%" & txtSearch.Text.Trim() & "%", "@status", ddlStatus.SelectedValue, "@barangay", CInt(ddlBarangay.SelectedValue))
        gvSubmissions.DataBind()
    End Sub

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        BindGrid()
    End Sub

    Protected Sub gvSubmissions_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If e.CommandName <> "ReviewRow" Then Return
        Dim submissionId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), submissionId) Then Return
        Dim row As DataRow = Db.QueryRow("SELECT s.date_id, b.barangay_name, a.activity_name, p.period_name, p.submission_deadline, s.date_submitted, s.is_late, s.file_name FROM submissions s JOIN barangays b ON b.barangay_id = s.barangay_id JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id WHERE s.date_id = @id AND s.submission_status = 'Pending'", "@id", submissionId)
        If row Is Nothing Then Return
        hfSubmissionId.Value = submissionId.ToString()
        Dim late As Boolean = Convert.ToInt32(row("is_late")) = 1
        litReviewInfo.Text = "<p><b>" & Ui.H(row("barangay_name")) & "</b> - " & Ui.H(row("activity_name")) & " (" & Ui.H(row("period_name")) & ")<br />" &
            "Deadline: " & Ui.DateTimeText(row("submission_deadline")) & " &nbsp; Submitted: " & Ui.DateTimeText(row("date_submitted")) & If(late, " " & Ui.Badge("Late"), "") & "<br />" &
            "File: <a href=""" & ResolveUrl("~/Download.aspx") & "?t=submission&amp;id=" & submissionId & """>" & Ui.H(row("file_name")) & "</a><br />" &
            "Score if confirmed: <b>" & Ui.ScoreText(Scoring.ScoreFor(late)) & "</b></p>"
        txtDenyReason.Text = ""
        pnlReview.Visible = True
    End Sub

    Protected Sub btnConfirm_Click(sender As Object, e As EventArgs)
        Dim submissionId As Integer = CInt(hfSubmissionId.Value)
        Dim row As DataRow = Db.QueryRow("SELECT is_late FROM submissions WHERE date_id = @id AND submission_status = 'Pending'", "@id", submissionId)
        If row Is Nothing Then
            Ui.Notice(litMessage, "This submission was already reviewed.", False)
            pnlReview.Visible = False
            BindGrid()
            Return
        End If
        Dim score As Decimal = Scoring.ScoreFor(Convert.ToInt32(row("is_late")) = 1)
        Db.Execute("UPDATE submissions SET submission_status = 'Confirmed', score = @score, confirmed_by = @user, confirmation_date = NOW(), remarks = @remark, denial_reason = NULL, date_modified = NOW() WHERE date_id = @id AND submission_status = 'Pending'",
                   "@score", score, "@user", Auth.UserId, "@remark", ddlRemark.SelectedValue, "@id", submissionId)
        pnlReview.Visible = False
        Ui.Notice(litMessage, "Submission confirmed (" & Ui.ScoreText(score) & " point).", True)
        BindGrid()
    End Sub

    Protected Sub btnDeny_Click(sender As Object, e As EventArgs)
        Dim submissionId As Integer = CInt(hfSubmissionId.Value)
        If txtDenyReason.Text.Trim().Length = 0 Then
            Ui.Notice(litMessage, "Please enter a reason for denying the submission.", False)
            Return
        End If
        Dim attachmentPath As String = Nothing
        If fuDenial.HasFile Then
            Dim attachmentName As String = ""
            Dim errorMessage As String = ""
            If Not Uploads.Save(fuDenial, "denials", attachmentPath, attachmentName, errorMessage) Then
                Ui.Notice(litMessage, errorMessage, False)
                Return
            End If
        End If
        Dim changed As Integer = Db.Execute("UPDATE submissions SET submission_status = 'Denied', score = NULL, confirmed_by = @user, confirmation_date = NOW(), remarks = NULL, denial_reason = @reason, denial_attachment = @attachment, date_modified = NOW() WHERE date_id = @id AND submission_status = 'Pending'",
                                            "@user", Auth.UserId, "@reason", txtDenyReason.Text.Trim(), "@attachment", attachmentPath, "@id", submissionId)
        If changed = 0 Then Uploads.Delete(attachmentPath)
        pnlReview.Visible = False
        Ui.Notice(litMessage, "Submission denied. The barangay can now resubmit.", True)
        BindGrid()
    End Sub

    Protected Sub btnCancelReview_Click(sender As Object, e As EventArgs)
        pnlReview.Visible = False
    End Sub

End Class
