Imports System.Data
Imports MySql.Data.MySqlClient

Partial Class Super_Accounts
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then BindGrid()
    End Sub

    Private Sub BindGrid()
        gvUsers.DataSource = Db.Query("SELECT u.user_id, u.username, CONCAT(u.first_name, ' ', u.last_name) AS full_name, u.role, COALESCE(b.barangay_name, '-') AS barangay_name, u.last_login, u.account_status FROM users u LEFT JOIN barangays b ON b.barangay_id = u.barangay_id ORDER BY u.role, b.barangay_name")
        gvUsers.DataBind()
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        Dim free As DataTable = Db.Query("SELECT barangay_id, barangay_name FROM barangays WHERE status = 'Active' AND barangay_id NOT IN (SELECT barangay_id FROM users WHERE role = 'Barangay Admin' AND barangay_id IS NOT NULL) ORDER BY barangay_name")
        If free.Rows.Count = 0 Then
            Ui.Notice(litMessage, "Every active barangay already has an admin account.", False)
            Return
        End If
        Ui.Fill(ddlBarangay, free, "barangay_name", "barangay_id")
        txtUsername.Text = ""
        txtFirst.Text = ""
        txtMiddle.Text = ""
        txtLast.Text = ""
        txtSuffix.Text = ""
        txtContact.Text = ""
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
        If username.Length < 4 OrElse txtFirst.Text.Trim().Length = 0 OrElse txtLast.Text.Trim().Length = 0 OrElse ddlBarangay.Items.Count = 0 Then
            Ui.Notice(litMessage, "Barangay, a username of at least 4 characters, first name and last name are required.", False)
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
        Dim barangayId As Integer = CInt(ddlBarangay.SelectedValue)
        If Db.ScalarInt("SELECT COUNT(*) FROM users WHERE role = 'Barangay Admin' AND barangay_id = @b", "@b", barangayId) > 0 Then
            Ui.Notice(litMessage, "This barangay already has an admin account.", False)
            Return
        End If
        Dim hash As String = Auth.HashPassword(txtPassword.Text)
        Try
            Db.InTransaction(Sub(tx As MySqlTransaction)
                                 Dim newId As Long = Db.TxExecute(tx, "INSERT INTO users (username, password_hash, first_name, middle_name, last_name, suffix, contact_number, role, barangay_id, account_status, created_by, password_changed) VALUES (@username, @hash, @first, @middle, @last, @suffix, @contact, 'Barangay Admin', @barangay, 'Active', @creator, NOW())",
                                                                    "@username", username, "@hash", hash, "@first", txtFirst.Text.Trim(), "@middle", Clean(txtMiddle.Text), "@last", txtLast.Text.Trim(), "@suffix", Clean(txtSuffix.Text), "@contact", Clean(txtContact.Text), "@barangay", barangayId, "@creator", Auth.UserId)
                                 Db.TxExecute(tx, "UPDATE barangays SET user_id = @u, date_modified = NOW() WHERE barangay_id = @b", "@u", newId, "@b", barangayId)
                             End Sub)
        Catch
            Ui.Notice(litMessage, "The account could not be created. Please try again.", False)
            Return
        End Try
        pnlForm.Visible = False
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
                Db.Execute("UPDATE users SET account_status = @s, date_modified = NOW() WHERE user_id = @id", "@s", newStatus, "@id", userId)
                Ui.Notice(litMessage, "Account is now " & newStatus & ".", True)
                BindGrid()
        End Select
    End Sub

    Protected Sub btnReset_Click(sender As Object, e As EventArgs)
        If Not Auth.PasswordIsStrong(txtResetPassword.Text) Then
            Ui.Notice(litMessage, "Password must be at least 8 characters and include letters and numbers.", False)
            Return
        End If
        Db.Execute("UPDATE users SET password_hash = @hash, password_changed = NOW(), date_modified = NOW() WHERE user_id = @id", "@hash", Auth.HashPassword(txtResetPassword.Text), "@id", CInt(hfResetUserId.Value))
        pnlReset.Visible = False
        Ui.Notice(litMessage, "Password updated.", True)
    End Sub

    Protected Sub btnCancelReset_Click(sender As Object, e As EventArgs)
        pnlReset.Visible = False
    End Sub

End Class
