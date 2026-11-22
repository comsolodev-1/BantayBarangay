Imports System.Data
Imports MySql.Data.MySqlClient

Partial Class Super_Accounts
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlFilterBarangay, Db.Query("SELECT barangay_code, barangay_name FROM barangays ORDER BY barangay_name"), "barangay_name", "barangay_code")
        ddlFilterBarangay.Items.Insert(0, New ListItem("All barangays", ""))
        BindGrid()
    End Sub

    Private Sub BindGrid()
        gvUsers.DataSource = Db.Query(
            "SELECT u.user_id, u.username, COALESCE(u.display_name, u.username) AS display_name, r.role_name AS role, " &
            "COALESCE(b.barangay_name, '-') AS barangay_name, u.last_login, u.account_status " &
            "FROM users u JOIN roles r ON r.role_id = u.role_id LEFT JOIN barangays b ON b.barangay_code = u.barangay_code " &
            "WHERE (@b = '' OR u.barangay_code = @b) " &
            "AND (u.username LIKE @search OR u.display_name LIKE @search OR b.barangay_name LIKE @search) " &
            "ORDER BY r.role_name, b.barangay_name, u.username",
            "@b", ddlFilterBarangay.SelectedValue, "@search", "%" & txtAccountSearch.Text.Trim() & "%")
        gvUsers.DataBind()
    End Sub

    Protected Sub AccountFilterChanged(sender As Object, e As EventArgs)
        BindGrid()
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        Dim free As DataTable = Db.Query("SELECT barangay_code, barangay_name FROM barangays WHERE status = 'Active' AND barangay_code NOT IN (SELECT barangay_code FROM users WHERE role_id = (SELECT role_id FROM roles WHERE role_name = 'Barangay Admin') AND barangay_code IS NOT NULL) ORDER BY barangay_name")
        Ui.Fill(ddlBarangay, free, "barangay_name", "barangay_code")
        btnSave.Enabled = free.Rows.Count > 0
        ddlBarangay.Enabled = free.Rows.Count > 0
        litAvailability.Text = If(free.Rows.Count > 0, "", "<p role=""status"">Every active barangay already has an admin account.</p>")
        txtUsername.Text = ""
        txtDisplayName.Text = ""
        txtContact.Text = ""
        ddlNewStatus.SelectedValue = "Active"
        pnlForm.Visible = True
        pnlReset.Visible = False
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        pnlForm.Visible = False
    End Sub

    Private Shared Function Clean(value As String) As Object
        If value Is Nothing OrElse value.Trim().Length = 0 Then Return Nothing
        Return value.Trim()
    End Function

    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        Dim username As String = txtUsername.Text.Trim()
        If txtDisplayName.Text.Trim().Length > 100 OrElse username.Length > 50 OrElse txtContact.Text.Trim().Length > 15 Then
            Ui.Notice(litMessage, "Check the length of the account fields.", False)
            Return
        End If
        If username.Length < 4 OrElse ddlBarangay.Items.Count = 0 Then
            Ui.Notice(litMessage, "Select a barangay and enter a username of at least 4 characters.", False)
            Return
        End If
        If Not Auth.PasswordIsStrong(txtPassword.Text) Then
            Ui.Notice(litMessage, "Password must be at least 8 characters and include letters and numbers.", False)
            Return
        End If
        If Db.ScalarInt("SELECT COUNT(*) FROM users WHERE username = @u", "@u", username) > 0 Then
            Ui.Notice(litMessage, "That username is already taken.", False)
            Return
        End If
        Dim barangayCode As String = ddlBarangay.SelectedValue
        Dim hash As String = Auth.HashPassword(txtPassword.Text)
        Dim created As Boolean = False
        Try
            Db.InTransaction(Sub(tx As MySqlTransaction)
                                 Dim status As Object = Db.TxScalar(tx,
                                     "SELECT status FROM barangays WHERE barangay_code = @b FOR UPDATE", "@b", barangayCode)
                                 If status Is Nothing OrElse CStr(status) <> "Active" Then Return
                                 Dim assigned As Object = Db.TxScalar(tx,
                                     "SELECT user_id FROM users WHERE barangay_code = @b AND " &
                                     "role_id = (SELECT role_id FROM roles WHERE role_name = 'Barangay Admin') LIMIT 1",
                                     "@b", barangayCode)
                                 If assigned IsNot Nothing Then Return
                                 Dim newId As Long = Db.TxExecute(tx,
                                     "INSERT INTO users (username, display_name, password_hash, contact_number, role_id, barangay_code, account_status, created_by, password_changed) " &
                                     "VALUES (@username, @name, @hash, @contact, (SELECT role_id FROM roles WHERE role_name = 'Barangay Admin'), @barangay, @status, @creator, NOW())",
                                     "@username", username, "@name", Clean(txtDisplayName.Text), "@hash", hash,
                                     "@contact", Clean(txtContact.Text), "@barangay", barangayCode,
                                     "@status", ddlNewStatus.SelectedValue, "@creator", Auth.UserId)
                                 Db.TxExecute(tx, "UPDATE barangays SET user_id = @u, date_modified = NOW() WHERE barangay_code = @b",
                                              "@u", newId, "@b", barangayCode)
                                 created = True
                             End Sub)
        Catch ex As MySqlException
            Ui.Notice(litMessage, If(ex.Number = 1062, "That username is already taken.", "The account could not be created. Please try again."), False)
            Return
        End Try
        If Not created Then
            Ui.Notice(litMessage, "This barangay is inactive or already has an admin account.", False)
            Return
        End If
        pnlForm.Visible = False
        txtAccountSearch.Text = ""
        ddlFilterBarangay.SelectedValue = barangayCode
        Ui.Notice(litMessage, "Account created. Share the username and initial password with the barangay and ask them to change it.", True)
        BindGrid()
    End Sub

    Protected Sub gvUsers_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim userId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), userId) Then Return
        Dim user As DataRow = Db.QueryRow("SELECT user_id, username, account_status FROM users WHERE user_id = @id", "@id", userId)
        If user Is Nothing Then Return
        Select Case e.CommandName
            Case "ResetRow"
                If userId = Auth.UserId Then
                    Ui.Notice(litMessage, "Use Settings to change your own password.", False)
                    Return
                End If
                hfResetUserId.Value = userId.ToString()
                litResetInfo.Text = "<p>Account: <b>" & Ui.H(user("username")) & "</b></p>"
                txtResetPassword.Text = ""
                pnlReset.Visible = True
                pnlForm.Visible = False
            Case "ToggleRow"
                If userId = Auth.UserId Then
                    Ui.Notice(litMessage, "You cannot deactivate your own account.", False)
                    Return
                End If
                Dim newStatus As String = If(CStr(user("account_status")) = "Active", "Inactive", "Active")
                Dim changed As Integer = Db.Execute("UPDATE users SET account_status = @s, session_version = session_version + 1, date_modified = NOW() WHERE user_id = @id AND account_status = @previous", "@s", newStatus, "@id", userId, "@previous", CStr(user("account_status")))
                Ui.Notice(litMessage, If(changed > 0, "Account is now " & newStatus & ".", "The account status changed. Check the list and try again."), changed > 0)
                BindGrid()
        End Select
    End Sub

    Protected Sub btnReset_Click(sender As Object, e As EventArgs)
        If CInt(hfResetUserId.Value) = Auth.UserId Then
            pnlReset.Visible = False
            Ui.Notice(litMessage, "Use Settings to change your own password.", False)
            Return
        End If
        If Not Auth.PasswordIsStrong(txtResetPassword.Text) Then
            Ui.Notice(litMessage, "Password must be at least 8 characters and include letters and numbers.", False)
            Return
        End If
        Db.Execute("UPDATE users SET password_hash = @hash, password_changed = NOW(), session_version = session_version + 1, date_modified = NOW() WHERE user_id = @id", "@hash", Auth.HashPassword(txtResetPassword.Text), "@id", CInt(hfResetUserId.Value))
        pnlReset.Visible = False
        Ui.Notice(litMessage, "Password updated.", True)
    End Sub

    Protected Sub btnCancelReset_Click(sender As Object, e As EventArgs)
        pnlReset.Visible = False
    End Sub

End Class
