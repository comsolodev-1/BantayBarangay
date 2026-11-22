Imports System.Data
Imports System.Globalization

Partial Class Super_ImportantDates
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlTargetBarangay, Db.Query("SELECT barangay_code, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_code")
        BindGrid()
    End Sub

    Private Sub BindGrid()
        gvDates.DataSource = Db.Query("SELECT date_id, event_date, title, event_type, location, visibility_type, COALESCE((SELECT barangay_name FROM barangays b WHERE b.barangay_code = important_dates.target_barangay_code), 'All Barangays') AS audience, status FROM important_dates ORDER BY event_date DESC")
        gvDates.DataBind()
    End Sub

    Private Sub ClearForm()
        hfId.Value = "0"
        editAudienceFields.Visible = False
        ddlTargetBarangay.ClearSelection()
        txtTitle.Text = ""
        txtDescription.Text = ""
        txtDate.Text = ""
        txtDate.Attributes.Remove("min")
        txtStart.Text = ""
        txtEnd.Text = ""
        txtLocation.Text = ""
        txtReminder.Text = ""
        txtReminder.Attributes.Remove("min")
        ddlType.SelectedIndex = 0
        ddlVisibility.SelectedValue = "All"
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        ClearForm()
        Dim minimumDate As String = CDate(Db.Scalar("SELECT CURDATE()")).ToString("yyyy-MM-dd", CultureInfo.InvariantCulture)
        txtDate.Attributes("min") = minimumDate
        txtReminder.Attributes("min") = minimumDate
        litFormTitle.Text = "Add Important Date"
        pnlForm.Visible = True
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        pnlForm.Visible = False
    End Sub

    Private Shared Function Clean(value As String) As Object
        If value Is Nothing OrElse value.Trim().Length = 0 Then Return Nothing
        Return value.Trim()
    End Function

    Private Shared Function TimeValue(text As String) As Object
        Dim parsed As TimeSpan
        If text IsNot Nothing AndAlso TimeSpan.TryParse(text, parsed) Then Return parsed
        Return Nothing
    End Function

    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        Dim id As Integer
        If Not Integer.TryParse(hfId.Value, id) Then Return
        Dim eventDate As DateTime
        If txtTitle.Text.Trim().Length = 0 OrElse
            Not DateTime.TryParseExact(txtDate.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, eventDate) OrElse eventDate.Year < 1000 Then
            Ui.Notice(litMessage, "Title and a valid date are required.", False)
            Return
        End If
        Dim today As DateTime = CDate(Db.Scalar("SELECT CURDATE()"))
        If id = 0 AndAlso eventDate.Date < today Then
            Ui.Notice(litMessage, "The event date must be today or later.", False)
            Return
        End If
        Dim reminder As Object = Nothing
        Dim reminderValue As DateTime
        If txtReminder.Text.Trim().Length > 0 Then
            If Not DateTime.TryParseExact(txtReminder.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, reminderValue) OrElse reminderValue.Year < 1000 Then
                Ui.Notice(litMessage, "Choose a valid reminder date.", False)
                Return
            End If
            If id = 0 AndAlso reminderValue.Date < today Then
                Ui.Notice(litMessage, "The reminder date must be today or later.", False)
                Return
            End If
            reminder = reminderValue.Date
        End If

        Dim visibility As String = If(id = 0, "All", ddlVisibility.SelectedValue)
        Dim targetRole As Object = If(visibility = "Specific Role", Auth.BarangayAdminRole, Nothing)
        Dim targetBarangay As String = Nothing
        If visibility = "Specific Barangay" Then
            For Each item As ListItem In ddlTargetBarangay.Items
                If Not item.Selected Then Continue For
                If targetBarangay IsNot Nothing Then
                    Ui.Notice(litMessage, "Choose one barangay when editing an individual copy.", False)
                    Return
                End If
                targetBarangay = item.Value
            Next
            If targetBarangay Is Nothing Then
                Ui.Notice(litMessage, "Choose a target barangay.", False)
                Return
            End If
        End If

        Dim status As String = If(eventDate.Date < today, "Past", "Upcoming")

        Try
            Db.InTransaction(Sub(tx)
                If id = 0 Then
                    Db.TxExecute(tx, "INSERT INTO important_dates (title, description, event_date, start_time, end_time, event_type, created_by, visibility_type, location, status, reminder_date) VALUES (@title, @description, @date, @start, @end, @type, @user, 'All', @location, @status, @reminder)",
                        "@title", txtTitle.Text.Trim(), "@description", Clean(txtDescription.Text), "@date", eventDate.Date, "@start", TimeValue(txtStart.Text), "@end", TimeValue(txtEnd.Text), "@type", ddlType.SelectedValue, "@user", Auth.UserId, "@location", Clean(txtLocation.Text), "@status", status, "@reminder", reminder)
                    Ui.Notice(litMessage, "Date added.", True)
                Else
                    Db.TxExecute(tx, "UPDATE important_dates SET title = @title, description = @description, event_date = @date, start_time = @start, end_time = @end, event_type = @type, visibility_type = @visibility, target_role_id = (SELECT role_id FROM roles WHERE role_name = @role), target_barangay_code = @barangay, location = @location, status = @status, reminder_date = @reminder, date_modified = NOW() WHERE date_id = @id",
                        "@title", txtTitle.Text.Trim(), "@description", Clean(txtDescription.Text), "@date", eventDate.Date, "@start", TimeValue(txtStart.Text), "@end", TimeValue(txtEnd.Text), "@type", ddlType.SelectedValue, "@visibility", visibility, "@role", targetRole, "@barangay", targetBarangay, "@location", Clean(txtLocation.Text), "@status", status, "@reminder", reminder, "@id", id)
                    Ui.Notice(litMessage, "Date updated.", True)
                End If
            End Sub)
        Catch
            Ui.Notice(litMessage, "The date could not be saved. Please try again.", False)
            Return
        End Try
        pnlForm.Visible = False
        BindGrid()
    End Sub

    Protected Sub gvDates_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim id As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), id) Then Return
        Select Case e.CommandName
            Case "EditRow"
                Dim row As DataRow = Db.QueryRow("SELECT t.*, r.role_name AS target_role FROM important_dates t LEFT JOIN roles r ON r.role_id = t.target_role_id WHERE date_id = @id", "@id", id)
                If row Is Nothing Then Return
                ClearForm()
                editAudienceFields.Visible = True
                hfId.Value = id.ToString()
                txtTitle.Text = Convert.ToString(row("title"))
                txtDescription.Text = Convert.ToString(row("description"))
                txtDate.Text = Convert.ToDateTime(row("event_date")).ToString("yyyy-MM-dd")
                If Not IsDBNull(row("start_time")) Then txtStart.Text = CType(row("start_time"), TimeSpan).ToString("hh\:mm")
                If Not IsDBNull(row("end_time")) Then txtEnd.Text = CType(row("end_time"), TimeSpan).ToString("hh\:mm")
                txtLocation.Text = Convert.ToString(row("location"))
                ddlType.SelectedValue = Convert.ToString(row("event_type"))
                ddlVisibility.SelectedValue = Convert.ToString(row("visibility_type"))
                If Not IsDBNull(row("reminder_date")) Then txtReminder.Text = Convert.ToDateTime(row("reminder_date")).ToString("yyyy-MM-dd")
                If Not IsDBNull(row("target_barangay_code")) AndAlso ddlTargetBarangay.Items.FindByValue(row("target_barangay_code").ToString()) IsNot Nothing Then ddlTargetBarangay.SelectedValue = row("target_barangay_code").ToString()
                litFormTitle.Text = "Edit Important Date"
                pnlForm.Visible = True
            Case "DeleteRow"
                Db.Execute("DELETE FROM important_dates WHERE date_id = @id", "@id", id)
                Ui.Notice(litMessage, "Date deleted.", True)
                BindGrid()
        End Select
    End Sub

End Class
