Imports System.Data
Imports System.Globalization
Imports MySql.Data.MySqlClient

Partial Class Super_Activities
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        For Each frequency As String In PeriodHelper.Frequencies
            ddlFrequency.Items.Add(frequency)
        Next
        Ui.Fill(cblBarangays, Db.Query("SELECT barangay_code, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_code")
        BindGrid()
    End Sub

    Private Sub BindGrid()
        Dim sql As String = "SELECT a.activity_id, a.activity_name, a.description, a.frequency, a.activity_status, a.is_public, " &
            "(SELECT MAX(p.submission_deadline) FROM reporting_period p WHERE p.activity_id = a.activity_id) AS latest_deadline, " &
            "(SELECT COUNT(*) FROM activity_barangays ab WHERE ab.activity_id = a.activity_id) AS barangay_count, " &
            "(SELECT COUNT(*) FROM submissions s JOIN reporting_period p ON p.period_id = s.period_id WHERE p.activity_id = a.activity_id) AS submission_count " &
            "FROM activities a WHERE a.activity_name LIKE @search"
        Dim data As DataTable
        If ddlStatusFilter.SelectedValue.Length > 0 Then
            data = Db.Query(sql & " AND a.activity_status = @status ORDER BY a.date_created DESC", "@search", "%" & txtSearch.Text.Trim() & "%", "@status", ddlStatusFilter.SelectedValue)
        Else
            data = Db.Query(sql & " ORDER BY a.date_created DESC", "@search", "%" & txtSearch.Text.Trim() & "%")
        End If
        gvActivities.DataSource = data
        gvActivities.DataBind()
    End Sub

    Protected Sub btnFilter_Click(sender As Object, e As EventArgs)
        BindGrid()
    End Sub

    Private Sub ClearForm()
        hfActivityId.Value = "0"
        txtName.Text = ""
        txtDescription.Text = ""
        txtRequirements.Text = ""
        txtDeadline.Text = ""
        txtDeadline.Enabled = True
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

    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        Dim activityId As Integer = CInt(hfActivityId.Value)
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
        If activityId = 0 AndAlso Not DateTime.TryParse(txtDeadline.Text, deadline) Then
            Ui.Notice(litMessage, "Please choose a valid submission deadline.", False)
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
        Dim oldTemplate As Object = Nothing
        Try
            If activityId = 0 Then
                Db.InTransaction(Sub(tx As MySqlTransaction)
                                     Dim newId As Long = Db.TxExecute(tx, "INSERT INTO activities (activity_name, description, frequency, instructions, template_file_name, template_file_type, template_link, default_deadline, required_submission, activity_status, is_public, created_by) VALUES (@name, @description, @frequency, @instructions, @tname, @ttype, @tlink, @deadline, 1, 'Active', @public, @user)",
                                                                        "@name", name, "@description", Clean(txtDescription.Text), "@frequency", ddlFrequency.SelectedValue, "@instructions", Clean(txtRequirements.Text), "@tname", templateName, "@ttype", templateType, "@tlink", templatePath, "@deadline", deadline.Date, "@public", isPublic, "@user", Auth.UserId)
                                     PeriodHelper.CreateInTransaction(tx, newId, ddlFrequency.SelectedValue, deadline, Auth.UserId)
                                     For Each barangayCode As String In selected
                                         Db.TxExecute(tx, "INSERT INTO activity_barangays (activity_id, barangay_code) VALUES (@a, @b)", "@a", newId, "@b", barangayCode)
                                     Next
                                 End Sub)
                Ui.Notice(litMessage, "Activity created and assigned to " & selected.Count & " barangays.", True)
            Else
                Dim existing As DataRow = Db.QueryRow("SELECT template_link FROM activities WHERE activity_id = @id", "@id", activityId)
                If existing Is Nothing Then
                    Uploads.Delete(templatePath)
                    Return
                End If
                If templatePath IsNot Nothing AndAlso Not IsDBNull(existing("template_link")) Then oldTemplate = existing("template_link")
                Db.InTransaction(Sub(tx As MySqlTransaction)
                                     Dim status As Object = Db.TxScalar(tx,
                                         "SELECT activity_status FROM activities WHERE activity_id = @id FOR UPDATE", "@id", activityId)
                                     If status Is Nothing OrElse CStr(status) = "Archived" Then
                                         Throw New InvalidOperationException("Activity is unavailable.")
                                     End If
                                     Db.TxExecute(tx, "UPDATE activities SET activity_name = @name, description = @description, instructions = @instructions, is_public = @public, date_modified = NOW() WHERE activity_id = @id AND activity_status <> 'Archived'",
                                                  "@name", name, "@description", Clean(txtDescription.Text), "@instructions", Clean(txtRequirements.Text), "@public", isPublic, "@id", activityId)
                                     If templatePath IsNot Nothing Then
                                         Db.TxExecute(tx, "UPDATE activities SET template_file_name = @tname, template_file_type = @ttype, template_link = @tlink WHERE activity_id = @id", "@tname", templateName, "@ttype", templateType, "@tlink", templatePath, "@id", activityId)
                                     End If
                                     Db.TxExecute(tx, "DELETE FROM activity_barangays WHERE activity_id = @id", "@id", activityId)
                                     For Each barangayCode As String In selected
                                         Db.TxExecute(tx, "INSERT INTO activity_barangays (activity_id, barangay_code) VALUES (@a, @b)", "@a", activityId, "@b", barangayCode)
                                     Next
                                 End Sub)
                If oldTemplate IsNot Nothing Then Uploads.Delete(CStr(oldTemplate))
                Ui.Notice(litMessage, "Activity updated.", True)
            End If
        Catch
            Uploads.Delete(templatePath)
            Ui.Notice(litMessage, "The activity could not be saved. Please try again.", False)
            Return
        End Try
        pnlForm.Visible = False
        BindGrid()
    End Sub

    Protected Sub gvActivities_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        pnlExtend.Visible = False
        Dim activityId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), activityId) Then Return
        Dim activity As DataRow = Db.QueryRow("SELECT * FROM activities WHERE activity_id = @id AND activity_status <> 'Archived'", "@id", activityId)
        If activity Is Nothing Then Return

        Select Case e.CommandName
            Case "EditRow"
                ClearForm()
                hfActivityId.Value = activityId.ToString()
                txtName.Text = Convert.ToString(activity("activity_name"))
                txtDescription.Text = Convert.ToString(activity("description"))
                txtRequirements.Text = Convert.ToString(activity("instructions"))
                ddlFrequency.SelectedValue = Convert.ToString(activity("frequency"))
                ddlFrequency.Enabled = False
                txtDeadline.Enabled = False
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
                Dim periods As DataTable = Db.Query(
                    "SELECT period_id, CONCAT(period_name, ' - ', DATE_FORMAT(submission_deadline, '%b %e %Y, %h:%i %p')) AS label " &
                    "FROM reporting_period WHERE activity_id = @id ORDER BY submission_deadline DESC, period_id DESC",
                    "@id", activityId)
                Ui.Fill(ddlExtendPeriod, periods, "label", "period_id")
                txtExtension.Text = ""
                pnlExtend.Visible = True
                pnlForm.Visible = False
                pnlPeriod.Visible = False

            Case "AddPeriodRow"
                hfPeriodActivityId.Value = activityId.ToString()
                litPeriodInfo.Text = "<p><b>" & Ui.H(activity("activity_name")) & "</b> (" & Ui.H(activity("frequency")) & ")</p>"
                txtNewDeadline.Text = ""
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
        Dim newDeadline As DateTime
        If Not Integer.TryParse(hfExtendActivityId.Value, activityId) OrElse
            Not Integer.TryParse(ddlExtendPeriod.SelectedValue, periodId) OrElse
            Not DateTime.TryParseExact(txtExtension.Text, "yyyy-MM-dd'T'HH:mm", CultureInfo.InvariantCulture,
                                       DateTimeStyles.None, newDeadline) OrElse newDeadline <= DateTime.Now Then
            Ui.Notice(litExtensionMessage, "Choose a reporting period and a valid future date and time.", False)
            Return
        End If

        Dim extended As Boolean = False
        Db.InTransaction(Sub(tx As MySqlTransaction)
                             Dim status As Object = Db.TxScalar(tx,
                                 "SELECT activity_status FROM activities WHERE activity_id = @id FOR UPDATE", "@id", activityId)
                             If status Is Nothing OrElse CStr(status) = "Archived" Then Return

                             Dim previous As Object = Db.TxScalar(tx,
                                 "SELECT submission_deadline FROM reporting_period " &
                                 "WHERE period_id = @period AND activity_id = @id FOR UPDATE",
                                 "@period", periodId, "@id", activityId)
                             If previous Is Nothing OrElse newDeadline <= CDate(previous) Then Return

                             Db.TxExecute(tx,
                                 "UPDATE reporting_period SET submission_deadline = @deadline, period_status = 'Open', date_closed = NULL " &
                                 "WHERE period_id = @period AND @deadline > NOW()",
                                 "@deadline", newDeadline, "@period", periodId)
                             Dim saved As Object = Db.TxScalar(tx,
                                 "SELECT submission_deadline FROM reporting_period WHERE period_id = @period", "@period", periodId)
                             If CDate(saved) <> newDeadline Then Return

                             Db.TxExecute(tx,
                                 "UPDATE submissions SET is_late = date_submitted > @deadline, " &
                                 "score = CASE WHEN submission_status = 'Confirmed' THEN IF(date_submitted > @deadline, @late, @onTime) ELSE score END, " &
                                 "date_modified = NOW() " &
                                 "WHERE period_id = @period AND is_late <> (date_submitted > @deadline)",
                                 "@deadline", newDeadline, "@late", Scoring.LateScore, "@onTime", Scoring.OnTimeScore, "@period", periodId)
                             Db.TxExecute(tx,
                                 "UPDATE activities SET activity_status = 'Active', date_modified = NOW() WHERE activity_id = @id",
                                 "@id", activityId)
                             extended = True
                         End Sub)
        If Not extended Then
            Ui.Notice(litExtensionMessage, "The deadline must be later than the current deadline and the activity must be available.", False)
            Return
        End If
        pnlExtend.Visible = False
        Ui.Notice(litMessage, "Deadline extended. Submission scores were recalculated.", True)
        BindGrid()
    End Sub

    Protected Sub btnCancelExtension_Click(sender As Object, e As EventArgs)
        pnlExtend.Visible = False
    End Sub

    Protected Sub btnAddPeriod_Click(sender As Object, e As EventArgs)
        Dim activityId As Integer = CInt(hfPeriodActivityId.Value)
        Dim activity As DataRow = Db.QueryRow("SELECT frequency FROM activities WHERE activity_id = @id AND activity_status <> 'Archived'", "@id", activityId)
        Dim deadline As DateTime
        If activity Is Nothing OrElse Not DateTime.TryParse(txtNewDeadline.Text, deadline) Then
            Ui.Notice(litMessage, "Please choose a valid deadline.", False)
            Return
        End If
        Dim frequency As String = CStr(activity("frequency"))
        Dim periodName As String = PeriodHelper.NameFor(frequency, deadline)
        If Db.ScalarInt("SELECT COUNT(*) FROM reporting_period WHERE activity_id = @id AND period_name = @name", "@id", activityId, "@name", periodName) > 0 Then
            Ui.Notice(litMessage, "A period named """ & periodName & """ already exists for this activity.", False)
            Return
        End If
        Dim added As Boolean = False
        Db.InTransaction(Sub(tx As MySqlTransaction)
                             Dim status As Object = Db.TxScalar(tx,
                                 "SELECT activity_status FROM activities WHERE activity_id = @id FOR UPDATE", "@id", activityId)
                             If status Is Nothing OrElse CStr(status) = "Archived" OrElse
                                 Db.TxScalar(tx, "SELECT period_id FROM reporting_period WHERE activity_id = @id AND period_name = @name",
                                             "@id", activityId, "@name", periodName) IsNot Nothing Then Return
                             PeriodHelper.CreateInTransaction(tx, activityId, frequency, deadline, Auth.UserId)
                             Db.TxExecute(tx, "UPDATE activities SET activity_status = 'Active', date_modified = NOW() WHERE activity_id = @id", "@id", activityId)
                             added = True
                         End Sub)
        If Not added Then
            Ui.Notice(litMessage, "This activity is unavailable or the reporting period already exists.", False)
            Return
        End If
        pnlPeriod.Visible = False
        Ui.Notice(litMessage, "Period """ & periodName & """ added.", True)
        BindGrid()
    End Sub

    Protected Sub btnCancelPeriod_Click(sender As Object, e As EventArgs)
        pnlPeriod.Visible = False
    End Sub

End Class
