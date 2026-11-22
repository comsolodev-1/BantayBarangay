Imports System.Data
Imports System.Globalization
Imports MySql.Data.MySqlClient

Partial Class Super_Activities
    Inherits SuperPage

    Private Const DraftSelect As String = "SELECT p.period_id, p.activity_id, p.period_name, p.start_date, p.end_date, p.grace_days, a.activity_name " &
        "FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id WHERE p.submission_deadline IS NULL AND a.activity_status <> 'Archived'"

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        PeriodHelper.EnsureScheduledPeriods()
        If IsPostBack Then Return
        For Each frequency As String In PeriodHelper.Frequencies
            ddlFrequency.Items.Add(frequency)
        Next
        Ui.Fill(cblBarangays, Db.Query("SELECT barangay_code, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_code")
        BindGrid()
        OpenFirstDraft()
    End Sub

    Private Sub BindGrid()
        Dim sql As String = "SELECT a.activity_id, a.activity_name, a.description, a.frequency, a.activity_status, a.is_public, " &
            "p.period_id, p.period_name, p.submission_deadline, " & PeriodHelper.CutoffSql & " AS cutoff, " &
            "IF(p.period_id IS NULL AND a.activity_status <> 'Archived', 'No Period', " & PeriodHelper.StatusSql & ") AS period_status, " &
            "(SELECT COUNT(*) FROM activity_barangays ab WHERE ab.activity_id = a.activity_id) AS barangay_count, " &
            "(SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id WHERE p.activity_id = a.activity_id) AS submission_count " &
            "FROM activities a LEFT JOIN reporting_period p ON p.activity_id = a.activity_id WHERE a.activity_name LIKE @search"
        gvActivities.DataSource = Db.Query("SELECT * FROM (" & sql & ") periods WHERE (@status = '' OR period_status = @status) " &
                                          "ORDER BY activity_name, activity_id, period_status = 'Awaiting Deadline' DESC, submission_deadline DESC, period_id DESC",
                                          "@search", "%" & txtSearch.Text.Trim() & "%", "@status", ddlStatusFilter.SelectedValue)
        gvActivities.DataBind()
        Dim pending As Integer = PeriodHelper.PendingDeadlineCount()
        litPendingPeriods.Text = If(pending > 0, "<p>" & pending & " reporting period(s) are awaiting a deadline.</p>", "")
    End Sub

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        BindGrid()
    End Sub

    Private Sub ClearForm()
        hfActivityId.Value = "0"
        hfEditPeriodId.Value = "0"
        litEditPeriod.Text = ""
        txtName.Text = ""
        txtDescription.Text = ""
        txtRequirements.Text = ""
        txtDeadline.Text = ""
        txtDeadline.TextMode = TextBoxMode.Date
        txtDeadline.Attributes.Remove("step")
        pnlFrequencyRange.Visible = True
        txtFrequencyRange.Text = "12"
        txtGraceDays.Text = PeriodHelper.DefaultGraceDays.ToString()
        ddlFrequency.Enabled = True
        ddlFrequency.SelectedIndex = 0
        chkPublic.Checked = True
        litCurrentTemplate.Text = ""
        For Each item As ListItem In cblBarangays.Items
            item.Selected = True
        Next
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        ClearForm()
        pnlExtend.Visible = False
        litFormTitle.Text = "Create New Activity"
        pnlForm.Visible = True
        pnlPeriod.Visible = False
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        pnlForm.Visible = False
    End Sub

    Protected Sub btnAll_Click(sender As Object, e As EventArgs)
        For Each item As ListItem In cblBarangays.Items
            item.Selected = True
        Next
    End Sub

    Protected Sub btnNone_Click(sender As Object, e As EventArgs)
        For Each item As ListItem In cblBarangays.Items
            item.Selected = False
        Next
    End Sub

    Private Shared Function Clean(value As String) As Object
        If value Is Nothing OrElse value.Trim().Length = 0 Then Return Nothing
        Return value.Trim()
    End Function

    Private Shared Function TryDeadline(text As String, dateOnly As Boolean, ByRef value As DateTime) As Boolean
        Dim formats As String() = If(dateOnly, {"yyyy-MM-dd"}, {"yyyy-MM-dd'T'HH:mm", "yyyy-MM-dd'T'HH:mm:ss"})
        If Not DateTime.TryParseExact(text, formats, CultureInfo.InvariantCulture, DateTimeStyles.None, value) OrElse
            value.Year < 1000 OrElse value.Year >= 9999 Then Return False
        If dateOnly Then value = PeriodHelper.EndOfDay(value)
        Return True
    End Function

    Private Shared Function TryGraceDays(text As String, ByRef value As Integer) As Boolean
        Return Integer.TryParse(text, value) AndAlso value >= 0 AndAlso value <= PeriodHelper.MaximumGraceDays
    End Function

    Private Shared Function LockActivity(tx As MySqlTransaction, activityId As Integer) As DataRow
        Return Db.TxRow(tx, "SELECT a.*, CURDATE() AS today, NOW() AS now_at FROM activities a WHERE activity_id = @id AND activity_status <> 'Archived' FOR UPDATE", "@id", activityId)
    End Function

    Private Shared Function LockPeriod(tx As MySqlTransaction, activityId As Integer, periodId As Integer) As DataRow
        Return Db.TxRow(tx, "SELECT * FROM reporting_period WHERE activity_id = @activity AND period_id = @period FOR UPDATE", "@activity", activityId, "@period", periodId)
    End Function

    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        Dim activityId As Integer
        Dim periodId As Integer
        If Not Integer.TryParse(hfActivityId.Value, activityId) OrElse Not Integer.TryParse(hfEditPeriodId.Value, periodId) Then Return
        Dim name As String = txtName.Text.Trim()
        If name.Length = 0 Then
            Ui.Notice(litMessage, "Activity title is required.", False)
            Return
        End If
        Dim selected As New List(Of String)
        For Each item As ListItem In cblBarangays.Items
            If item.Selected Then selected.Add(item.Value)
        Next
        If selected.Count = 0 Then
            Ui.Notice(litMessage, "Assign the activity to at least one barangay.", False)
            Return
        End If
        Dim deadline As DateTime
        If Not TryDeadline(txtDeadline.Text, activityId = 0, deadline) Then
            Ui.Notice(litMessage, "Please choose a valid submission deadline.", False)
            Return
        End If
        Dim graceDays As Integer
        If Not TryGraceDays(txtGraceDays.Text, graceDays) Then
            Ui.Notice(litMessage, "Enter a whole number from 0 to 365 for grace days.", False)
            Return
        End If
        Dim frequencyRange As Integer
        Dim frequency As String = ddlFrequency.SelectedValue
        If frequency <> "General" AndAlso (Not Integer.TryParse(txtFrequencyRange.Text, frequencyRange) OrElse
            frequencyRange < 0 OrElse frequencyRange > PeriodHelper.MaximumRangeMonths) Then
            Ui.Notice(litMessage, "Enter a frequency range from 0 to 120 months.", False)
            Return
        End If

        Dim templatePath As String = Nothing
        Dim templateName As String = Nothing
        Dim errorMessage As String = ""
        If fuTemplate.HasFile Then
            If Not Uploads.Save(fuTemplate, "templates", templatePath, templateName, errorMessage) Then
                Ui.Notice(litMessage, errorMessage, False)
                Return
            End If
        End If
        Dim templateType As Object = Nothing
        If templateName IsNot Nothing Then templateType = IO.Path.GetExtension(templateName).TrimStart("."c).ToLowerInvariant()

        Dim isPublic As Integer = If(chkPublic.Checked, 1, 0)
        Dim oldTemplate As String = Nothing
        Dim refusal As String = Nothing
        Try
            If activityId = 0 Then
                Db.InTransaction(Sub(tx As MySqlTransaction)
                                     If deadline.Date < CDate(Db.TxScalar(tx, "SELECT CURDATE()")) Then
                                         refusal = "The submission deadline must be today or later."
                                         Return
                                     End If
                                     Dim firstStart As DateTime
                                     Dim firstEnd As DateTime
                                     PeriodHelper.RangeFor(frequency, deadline, firstStart, firstEnd)
                                     Dim nextStart As Object = If(frequencyRange > 0, CObj(firstEnd.AddDays(1)), Nothing)
                                     Dim newId As Long = Db.TxExecute(tx, "INSERT INTO activities (activity_name, description, frequency, instructions, template_file_name, template_file_type, template_link, default_deadline, frequency_range_months, next_period_start, required_submission, activity_status, is_public, created_by) VALUES (@name, @description, @frequency, @instructions, @tname, @ttype, @tlink, @deadline, @months, @next, 1, 'Active', @public, @user)",
                                                                        "@name", name, "@description", Clean(txtDescription.Text), "@frequency", frequency, "@instructions", Clean(txtRequirements.Text), "@tname", templateName, "@ttype", templateType, "@tlink", templatePath, "@deadline", deadline.Date, "@months", frequencyRange, "@next", nextStart, "@public", isPublic, "@user", Auth.UserId)
                                     PeriodHelper.CreateInTransaction(tx, newId, frequency, deadline, deadline, graceDays, Auth.UserId)
                                     For Each barangayCode As String In selected
                                         Db.TxExecute(tx, "INSERT INTO activity_barangays (activity_id, barangay_code) VALUES (@a, @b)", "@a", newId, "@b", barangayCode)
                                     Next
                                 End Sub)
            Else
                Db.InTransaction(Sub(tx As MySqlTransaction)
                                     Dim activity As DataRow = LockActivity(tx, activityId)
                                     If activity Is Nothing Then
                                         refusal = "This activity is no longer available."
                                         Return
                                     End If
                                     Dim period As DataRow = LockPeriod(tx, activityId, periodId)
                                     If period Is Nothing OrElse IsDBNull(period("submission_deadline")) Then
                                         refusal = "This reporting period is no longer available for editing."
                                         Return
                                     End If
                                     Dim deadlineChanged As Boolean = deadline <> CDate(period("submission_deadline"))
                                     If deadlineChanged AndAlso deadline <= CDate(activity("now_at")) Then
                                         refusal = "The new deadline must be in the future."
                                         Return
                                     End If
                                     Dim oldRange As Integer = CInt(activity("frequency_range_months"))
                                     If frequencyRange <> oldRange AndAlso
                                         CDate(activity("date_created")).Date.AddMonths(frequencyRange) < CDate(activity("today")) Then
                                         refusal = "The frequency range cannot end before today. It is counted from " & Ui.DateText(activity("date_created")) & "."
                                         Return
                                     End If
                                     Dim nextStart As Object = activity("next_period_start")
                                     If frequencyRange > 0 AndAlso IsDBNull(nextStart) Then
                                         Dim firstEnd As Object = Db.TxScalar(tx, "SELECT end_date FROM reporting_period WHERE activity_id = @id ORDER BY period_id LIMIT 1", "@id", activityId)
                                         nextStart = CDate(firstEnd).AddDays(1)
                                     End If
                                     Db.TxExecute(tx, "UPDATE activities SET activity_name = @name, description = @description, instructions = @instructions, is_public = @public, frequency_range_months = @months, next_period_start = @next, date_modified = NOW() WHERE activity_id = @id",
                                                  "@name", name, "@description", Clean(txtDescription.Text), "@instructions", Clean(txtRequirements.Text), "@public", isPublic, "@months", frequencyRange, "@next", nextStart, "@id", activityId)
                                     If deadlineChanged OrElse graceDays <> CInt(period("grace_days")) Then
                                         PeriodHelper.SaveDeadline(tx, periodId, deadline, graceDays)
                                     End If
                                     If templatePath IsNot Nothing Then
                                         oldTemplate = Convert.ToString(activity("template_link"))
                                         Db.TxExecute(tx, "UPDATE activities SET template_file_name = @tname, template_file_type = @ttype, template_link = @tlink WHERE activity_id = @id", "@tname", templateName, "@ttype", templateType, "@tlink", templatePath, "@id", activityId)
                                     End If
                                     Db.TxExecute(tx, "DELETE FROM activity_barangays WHERE activity_id = @id", "@id", activityId)
                                     For Each barangayCode As String In selected
                                         Db.TxExecute(tx, "INSERT INTO activity_barangays (activity_id, barangay_code) VALUES (@a, @b)", "@a", activityId, "@b", barangayCode)
                                     Next
                                 End Sub)
            End If
        Catch
            Uploads.Delete(templatePath)
            Ui.Notice(litMessage, "The activity could not be saved. Please try again.", False)
            Return
        End Try
        If refusal IsNot Nothing Then
            Uploads.Delete(templatePath)
            Ui.Notice(litMessage, refusal, False)
            Return
        End If
        If Not String.IsNullOrEmpty(oldTemplate) Then Uploads.Delete(oldTemplate)
        Ui.Notice(litMessage, If(activityId = 0, "Activity created and assigned to " & selected.Count & " barangays.", "Activity and reporting period updated."), True)
        pnlForm.Visible = False
        BindGrid()
    End Sub

    Protected Sub gvActivities_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        pnlExtend.Visible = False
        Dim keys As String() = Convert.ToString(e.CommandArgument).Split(":"c)
        Dim activityId As Integer
        Dim periodId As Integer
        If Not Integer.TryParse(keys(0), activityId) Then Return
        If keys.Length = 2 Then Integer.TryParse(keys(1), periodId)
        Dim activity As DataRow = Db.QueryRow("SELECT * FROM activities WHERE activity_id = @id AND activity_status <> 'Archived'", "@id", activityId)
        If activity Is Nothing Then Return

        Select Case e.CommandName
            Case "EditRow"
                Dim period As DataRow = Db.QueryRow("SELECT * FROM reporting_period WHERE activity_id = @activity AND period_id = @period AND submission_deadline IS NOT NULL",
                                                    "@activity", activityId, "@period", periodId)
                If period Is Nothing Then Return
                ClearForm()
                hfActivityId.Value = activityId.ToString()
                hfEditPeriodId.Value = periodId.ToString()
                litEditPeriod.Text = "<p>Editing deadline and grace days for <strong>" & Ui.H(period("period_name")) & "</strong>. Activity details and assignments are shared across its periods.</p>"
                txtName.Text = Convert.ToString(activity("activity_name"))
                txtDescription.Text = Convert.ToString(activity("description"))
                txtRequirements.Text = Convert.ToString(activity("instructions"))
                ddlFrequency.SelectedValue = Convert.ToString(activity("frequency"))
                ddlFrequency.Enabled = False
                pnlFrequencyRange.Visible = ddlFrequency.SelectedValue <> "General"
                txtFrequencyRange.Text = Convert.ToString(activity("frequency_range_months"))
                txtDeadline.TextMode = TextBoxMode.DateTimeLocal
                txtDeadline.Attributes("step") = "1"
                txtDeadline.Text = CDate(period("submission_deadline")).ToString("yyyy-MM-dd'T'HH:mm:ss", CultureInfo.InvariantCulture)
                txtGraceDays.Text = Convert.ToString(period("grace_days"))
                chkPublic.Checked = Convert.ToInt32(activity("is_public")) = 1
                If Not IsDBNull(activity("template_file_name")) Then litCurrentTemplate.Text = "<small>Current template: " & Ui.H(activity("template_file_name")) & " (upload a new file to replace it)</small>"
                Dim assigned As DataTable = Db.Query("SELECT barangay_code FROM activity_barangays WHERE activity_id = @id", "@id", activityId)
                For Each item As ListItem In cblBarangays.Items
                    item.Selected = False
                    For Each row As DataRow In assigned.Rows
                        If CStr(row("barangay_code")) = item.Value Then item.Selected = True
                    Next
                Next
                litFormTitle.Text = "Edit Activity"
                pnlForm.Visible = True
                pnlPeriod.Visible = False

            Case "ExtendRow"
                hfExtendActivityId.Value = activityId.ToString()
                hfDraftPeriodId.Value = "0"
                Dim periods As DataTable = Db.Query(
                    "SELECT period_id, CONCAT(period_name, ' - ', DATE_FORMAT(submission_deadline, '%b %e %Y, %h:%i %p')) AS label " &
                    "FROM reporting_period WHERE activity_id = @id AND submission_deadline IS NOT NULL ORDER BY submission_deadline DESC, period_id DESC",
                    "@id", activityId)
                Ui.Fill(ddlExtendPeriod, periods, "label", "period_id")
                If ddlExtendPeriod.Items.FindByValue(periodId.ToString()) IsNot Nothing Then ddlExtendPeriod.SelectedValue = periodId.ToString()
                pnlChooseExtendPeriod.Visible = True
                pnlDraftGrace.Visible = False
                litExtensionTitle.Text = "Extend Report Submission"
                litExtensionDetails.Text = "<p>Choose an existing reporting period and set a later deadline. Its grace days will apply to the new deadline.</p>"
                litExtensionMessage.Text = ""
                btnExtend.Text = "Extend Report Submission"
                txtExtension.Text = ""
                pnlExtend.Visible = True
                pnlForm.Visible = False
                pnlPeriod.Visible = False

            Case "DraftRow"
                Dim draft As DataRow = Db.QueryRow(DraftSelect & " AND a.activity_id = @activity AND p.period_id = @period", "@activity", activityId, "@period", periodId)
                If draft IsNot Nothing Then OpenDraft(draft)

            Case "AddPeriodRow"
                hfPeriodActivityId.Value = activityId.ToString()
                litPeriodInfo.Text = "<p><b>" & Ui.H(activity("activity_name")) & "</b> (" & Ui.H(activity("frequency")) & ")</p>"
                txtNewDeadline.Text = ""
                txtNewGraceDays.Text = PeriodHelper.DefaultGraceDays.ToString()
                pnlPeriod.Visible = True
                pnlForm.Visible = False

            Case "DeleteRow"
                Db.InTransaction(Sub(tx As MySqlTransaction)
                                     Db.TxExecute(tx,
                                         "UPDATE activities SET activity_status = 'Archived', date_archived = NOW(), date_modified = NOW() " &
                                         "WHERE activity_id = @id AND activity_status <> 'Archived'", "@id", activityId)
                                     Db.TxExecute(tx,
                                         "UPDATE reporting_period SET period_status = 'Closed', date_closed = COALESCE(date_closed, NOW()) " &
                                         "WHERE activity_id = @id AND period_status <> 'Closed'", "@id", activityId)
                                 End Sub)
                Ui.Notice(litMessage, "Activity deleted. Its submissions and files are retained for audit.", True)
        End Select
        BindGrid()
    End Sub

    Protected Sub btnExtend_Click(sender As Object, e As EventArgs)
        Dim activityId As Integer
        Dim periodId As Integer
        Dim isDraft As Boolean = hfDraftPeriodId.Value <> "0"
        Dim newDeadline As DateTime
        Dim graceDays As Integer
        If Not Integer.TryParse(hfExtendActivityId.Value, activityId) OrElse
            Not Integer.TryParse(If(isDraft, hfDraftPeriodId.Value, ddlExtendPeriod.SelectedValue), periodId) OrElse
            Not TryDeadline(txtExtension.Text, False, newDeadline) Then
            Ui.Notice(litExtensionMessage, "Choose a reporting period and a valid deadline.", False)
            Return
        End If
        If isDraft AndAlso Not TryGraceDays(txtDraftGraceDays.Text, graceDays) Then
            Ui.Notice(litExtensionMessage, "Enter a whole number from 0 to 365 for grace days.", False)
            Return
        End If

        Dim refusal As String = Nothing
        Db.InTransaction(Sub(tx As MySqlTransaction)
                             Dim activity As DataRow = LockActivity(tx, activityId)
                             Dim period As DataRow = If(activity Is Nothing, Nothing, LockPeriod(tx, activityId, periodId))
                             If period Is Nothing OrElse IsDBNull(period("submission_deadline")) <> isDraft Then
                                 refusal = "This reporting period changed. Close the form and select it again."
                                 Return
                             End If
                             If newDeadline <= CDate(activity("now_at")) OrElse
                                 (Not isDraft AndAlso newDeadline <= CDate(period("submission_deadline"))) Then
                                 refusal = If(isDraft, "Set the deadline to a future time.", "The deadline must be in the future and later than the current deadline.")
                                 Return
                             End If
                             PeriodHelper.SaveDeadline(tx, periodId, newDeadline, If(isDraft, graceDays, CInt(period("grace_days"))))
                             Db.TxExecute(tx, "UPDATE activities SET activity_status = 'Active', date_modified = NOW() WHERE activity_id = @id", "@id", activityId)
                         End Sub)
        If refusal IsNot Nothing Then
            Ui.Notice(litExtensionMessage, refusal, False)
            Return
        End If
        pnlExtend.Visible = False
        Ui.Notice(litMessage, If(isDraft, "Deadline set. The period is now open for submissions.", "Deadline extended. Submission scores were recalculated."), True)
        BindGrid()
        If isDraft Then OpenFirstDraft()
    End Sub

    Protected Sub btnCancelExtension_Click(sender As Object, e As EventArgs)
        pnlExtend.Visible = False
    End Sub

    Protected Sub btnAddPeriod_Click(sender As Object, e As EventArgs)
        Dim activityId As Integer
        Dim deadline As DateTime
        Dim graceDays As Integer
        If Not Integer.TryParse(hfPeriodActivityId.Value, activityId) OrElse Not TryDeadline(txtNewDeadline.Text, True, deadline) Then
            Ui.Notice(litMessage, "Please choose a valid deadline.", False)
            Return
        End If
        If Not TryGraceDays(txtNewGraceDays.Text, graceDays) Then
            Ui.Notice(litMessage, "Enter a whole number from 0 to 365 for grace days.", False)
            Return
        End If
        Dim refusal As String = Nothing
        Dim periodName As String = Nothing
        Db.InTransaction(Sub(tx As MySqlTransaction)
                             Dim activity As DataRow = LockActivity(tx, activityId)
                             If activity Is Nothing Then
                                 refusal = "This activity is no longer available."
                                 Return
                             End If
                             If deadline.Date < CDate(activity("today")) Then
                                 refusal = "The submission deadline must be today or later."
                                 Return
                             End If
                             Dim frequency As String = CStr(activity("frequency"))
                             Dim startDate As DateTime
                             Dim endDate As DateTime
                             PeriodHelper.RangeFor(frequency, deadline, startDate, endDate)
                             periodName = PeriodHelper.NameFor(frequency, deadline)
                             If PeriodHelper.ContainsPeriod(tx, activityId, startDate, endDate) Then
                                 refusal = periodName & " already exists. Choose Edit or Set Deadline on that period."
                                 Return
                             End If
                             PeriodHelper.CreateInTransaction(tx, activityId, frequency, deadline, deadline, graceDays, Auth.UserId)
                             Db.TxExecute(tx, "UPDATE activities SET activity_status = 'Active', date_modified = NOW() WHERE activity_id = @id", "@id", activityId)
                         End Sub)
        If refusal IsNot Nothing Then
            Ui.Notice(litMessage, refusal, False)
            Return
        End If
        pnlPeriod.Visible = False
        Ui.Notice(litMessage, "Period """ & periodName & """ added.", True)
        BindGrid()
    End Sub

    Protected Sub btnCancelPeriod_Click(sender As Object, e As EventArgs)
        pnlPeriod.Visible = False
    End Sub

    Private Sub OpenFirstDraft()
        Dim draft As DataRow = Db.QueryRow(DraftSelect & " ORDER BY p.start_date, p.period_id LIMIT 1")
        If draft IsNot Nothing Then OpenDraft(draft)
    End Sub

    Private Sub OpenDraft(draft As DataRow)
        hfExtendActivityId.Value = Convert.ToString(draft("activity_id"))
        hfDraftPeriodId.Value = Convert.ToString(draft("period_id"))
        litExtensionTitle.Text = "Set Reporting Period Deadline"
        litExtensionDetails.Text = "<p><strong>" & Ui.H(draft("activity_name")) & " - " & Ui.H(draft("period_name")) &
            "</strong></p><p>" & Ui.DateText(draft("start_date")) & " to " & Ui.DateText(draft("end_date")) &
            "</p><p>Barangays can submit once you set a deadline.</p>"
        litExtensionMessage.Text = ""
        txtExtension.Text = ""
        txtDraftGraceDays.Text = Convert.ToString(draft("grace_days"))
        pnlChooseExtendPeriod.Visible = False
        pnlDraftGrace.Visible = True
        btnExtend.Text = "Set Deadline"
        pnlForm.Visible = False
        pnlPeriod.Visible = False
        pnlExtend.Visible = True
    End Sub
End Class
