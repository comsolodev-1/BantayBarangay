Imports System.Data

Partial Class Super_ImportantDates
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlTargetBarangay, Db.Query("SELECT barangay_id, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_id")
        BindGrid()
    End Sub

    Private Sub BindGrid()
        gvDates.DataSource = Db.Query("SELECT date_id, event_date, title, event_type, location, visibility_type, status FROM important_dates ORDER BY event_date DESC")
        gvDates.DataBind()
    End Sub

    Private Sub ClearForm()
        hfId.Value = "0"
        txtTitle.Text = ""
        txtDescription.Text = ""
        txtDate.Text = ""
        txtStart.Text = ""
        txtEnd.Text = ""
        txtLocation.Text = ""
        txtReminder.Text = ""
        ddlType.SelectedIndex = 0
        ddlVisibility.SelectedValue = "All"
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        ClearForm()
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
        Dim eventDate As DateTime
        If txtTitle.Text.Trim().Length = 0 OrElse Not DateTime.TryParse(txtDate.Text, eventDate) Then
            Ui.Notice(litMessage, "Title and a valid date are required.", False)
            Return
        End If
        Dim reminder As Object = Nothing
        Dim reminderValue As DateTime
        If txtReminder.Text.Trim().Length > 0 AndAlso DateTime.TryParse(txtReminder.Text, reminderValue) Then reminder = reminderValue.Date

        Dim targetRole As Object = Nothing
        Dim targetBarangay As Object = Nothing
        If ddlVisibility.SelectedValue = "Specific Role" Then targetRole = ddlRole.SelectedValue
        If ddlVisibility.SelectedValue = "Specific Barangay" AndAlso ddlTargetBarangay.Items.Count > 0 Then targetBarangay = CInt(ddlTargetBarangay.SelectedValue)
        Dim id As Integer = CInt(hfId.Value)
        Dim status As String = If(eventDate.Date < DateTime.Today, "Past", "Upcoming")

        If id = 0 Then
            Db.Execute("INSERT INTO important_dates (title, description, event_date, start_time, end_time, event_type, created_by, visibility_type, target_role, target_barangay_id, location, status, reminder_date) VALUES (@title, @description, @date, @start, @end, @type, @user, @visibility, @role, @barangay, @location, @status, @reminder)",
                       "@title", txtTitle.Text.Trim(), "@description", Clean(txtDescription.Text), "@date", eventDate.Date, "@start", TimeValue(txtStart.Text), "@end", TimeValue(txtEnd.Text), "@type", ddlType.SelectedValue, "@user", Auth.UserId, "@visibility", ddlVisibility.SelectedValue, "@role", targetRole, "@barangay", targetBarangay, "@location", Clean(txtLocation.Text), "@status", status, "@reminder", reminder)
            Ui.Notice(litMessage, "Date added.", True)
        Else
            Db.Execute("UPDATE important_dates SET title = @title, description = @description, event_date = @date, start_time = @start, end_time = @end, event_type = @type, visibility_type = @visibility, target_role = @role, target_barangay_id = @barangay, location = @location, status = @status, reminder_date = @reminder, date_modified = NOW() WHERE date_id = @id",
                       "@title", txtTitle.Text.Trim(), "@description", Clean(txtDescription.Text), "@date", eventDate.Date, "@start", TimeValue(txtStart.Text), "@end", TimeValue(txtEnd.Text), "@type", ddlType.SelectedValue, "@visibility", ddlVisibility.SelectedValue, "@role", targetRole, "@barangay", targetBarangay, "@location", Clean(txtLocation.Text), "@status", status, "@reminder", reminder, "@id", id)
            Ui.Notice(litMessage, "Date updated.", True)
        End If
        pnlForm.Visible = False
        BindGrid()
    End Sub

    Protected Sub gvDates_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim id As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), id) Then Return
        Select Case e.CommandName
            Case "EditRow"
                Dim row As DataRow = Db.QueryRow("SELECT * FROM important_dates WHERE date_id = @id", "@id", id)
                If row Is Nothing Then Return
                ClearForm()
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
                If Not IsDBNull(row("target_barangay_id")) AndAlso ddlTargetBarangay.Items.FindByValue(row("target_barangay_id").ToString()) IsNot Nothing Then ddlTargetBarangay.SelectedValue = row("target_barangay_id").ToString()
                litFormTitle.Text = "Edit Important Date"
                pnlForm.Visible = True
            Case "DeleteRow"
                Db.Execute("DELETE FROM important_dates WHERE date_id = @id", "@id", id)
                Ui.Notice(litMessage, "Date deleted.", True)
                BindGrid()
        End Select
    End Sub

End Class
