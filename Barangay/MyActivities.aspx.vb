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
        Dim data As DataTable = Assignments.ForBarangay(Auth.BarangayId)
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
        Return "<p><b>" & Ui.H(label) & ":</b><br />" & Ui.H(value).Replace(vbLf, "<br />") & "</p>"
    End Function

    Private Sub ShowDetails(row As DataRow)
        Dim html As String = "<p><b>" & Ui.H(row("activity_name")) & "</b> - " & Ui.H(row("period_name")) & " (deadline " & Ui.DateText(row("submission_deadline")) & ")</p>"
        html &= TextBlock("Description", row("description"))
        html &= TextBlock("Requirements / Instructions", row("instructions"))
        If Not IsDBNull(row("template_file_name")) Then
            html &= "<p><a href=""" & ResolveUrl("~/Download.aspx") & "?t=template&amp;id=" & row("activity_id").ToString() & """>Download template: " & Ui.H(row("template_file_name")) & "</a></p>"
        End If
        If Not IsDBNull(row("submission_id")) Then
            html &= "<p>Status: " & Ui.Badge(row("submission_status")) & " &nbsp; Submitted " & Ui.DateTimeText(row("date_submitted"))
            If Convert.ToInt32(row("is_late")) = 1 Then html &= " " & Ui.Badge("Late")
            html &= "</p>"
            html &= TextBlock("Remarks", row("remarks"))
            html &= TextBlock("Denial reason", row("denial_reason"))
            If Not IsDBNull(row("denial_attachment")) Then
                html &= "<p><a href=""" & ResolveUrl("~/Download.aspx") & "?t=denial&amp;id=" & row("submission_id").ToString() & """>Download denial attachment</a></p>"
            End If
        End If
        litDetails.Text = html
        pnlDetails.Visible = True
        pnlSubmit.Visible = False
    End Sub

    Protected Sub gvActivities_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim periodId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), periodId) Then Return
        Dim row As DataRow = Assignments.PeriodForBarangay(periodId, Auth.BarangayId)
        If row Is Nothing Then Return
        Dim status As String = CStr(row("display_status"))

        Select Case e.CommandName
            Case "ShowDetails"
                ShowDetails(row)
            Case "StartSubmit"
                If status = "Not Submitted" OrElse status = "Denied" Then
                    SelectedPeriodId = periodId
                    litSubmitInfo.Text = "<p><b>" & Ui.H(row("activity_name")) & "</b> - " & Ui.H(row("period_name")) & "<br />Deadline: " & Ui.DateTimeText(row("submission_deadline")) & If(Convert.ToDateTime(row("submission_deadline")) < DateTime.Now, " <strong>Overdue - will be marked late (0.5 pt)</strong>", "") & "</p>"
                    pnlSubmit.Visible = True
                    pnlDetails.Visible = False
                End If
            Case "RemoveSubmission"
                If status = "Pending" Then
                    Dim file As DataRow = Db.QueryRow("SELECT file_path FROM submissions WHERE date_id = @id AND barangay_id = @b AND submission_status = 'Pending'", "@id", CInt(row("submission_id")), "@b", Auth.BarangayId)
                    If file IsNot Nothing Then
                        Db.Execute("DELETE FROM submissions WHERE date_id = @id AND barangay_id = @b AND submission_status = 'Pending'", "@id", CInt(row("submission_id")), "@b", Auth.BarangayId)
                        Uploads.Delete(CStr(file("file_path")))
                        Ui.Notice(litMessage, "Submission removed. You can submit the correct file now.", True)
                    End If
                End If
        End Select
        BindGrid()
    End Sub

    Protected Sub btnConfirmSubmit_Click(sender As Object, e As EventArgs)
        Dim row As DataRow = Assignments.PeriodForBarangay(SelectedPeriodId, Auth.BarangayId)
        If row Is Nothing Then
            Ui.Notice(litMessage, "This activity is not assigned to your barangay.", False)
            pnlSubmit.Visible = False
            Return
        End If
        Dim status As String = CStr(row("display_status"))
        If status <> "Not Submitted" AndAlso status <> "Denied" Then
            Ui.Notice(litMessage, "This activity cannot be submitted right now.", False)
            pnlSubmit.Visible = False
            Return
        End If

        Dim storedPath As String = ""
        Dim originalName As String = ""
        Dim errorMessage As String = ""
        If Not Uploads.Save(fuReport, "submissions", storedPath, originalName, errorMessage) Then
            Ui.Notice(litMessage, errorMessage, False)
            Return
        End If

        Dim isLate As Integer = If(DateTime.Now > Convert.ToDateTime(row("submission_deadline")), 1, 0)
        Try
            If IsDBNull(row("submission_id")) Then
                Db.Insert("INSERT INTO submissions (period_id, barangay_id, submitted_by, file_name, file_path, date_submitted, submission_status, submission_type, is_late) VALUES (@period, @barangay, @user, @fileName, @filePath, NOW(), 'Pending', 'Regular', @late)",
                          "@period", SelectedPeriodId, "@barangay", Auth.BarangayId, "@user", Auth.UserId, "@fileName", originalName, "@filePath", storedPath, "@late", isLate)
            Else
                Dim old As DataRow = Db.QueryRow("SELECT file_path, denial_attachment FROM submissions WHERE date_id = @id AND barangay_id = @b AND submission_status = 'Denied'", "@id", CInt(row("submission_id")), "@b", Auth.BarangayId)
                If old Is Nothing Then
                    Uploads.Delete(storedPath)
                    Ui.Notice(litMessage, "This submission can no longer be replaced.", False)
                    Return
                End If
                Db.Execute("UPDATE submissions SET file_name = @fileName, file_path = @filePath, submitted_by = @user, date_submitted = NOW(), submission_status = 'Pending', submission_type = 'Resubmission', is_late = @late, score = NULL, confirmed_by = NULL, confirmation_date = NULL, remarks = NULL, denial_reason = NULL, denial_attachment = NULL, resubmission_count = resubmission_count + 1, date_modified = NOW() WHERE date_id = @id AND barangay_id = @b",
                           "@fileName", originalName, "@filePath", storedPath, "@user", Auth.UserId, "@late", isLate, "@id", CInt(row("submission_id")), "@b", Auth.BarangayId)
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
