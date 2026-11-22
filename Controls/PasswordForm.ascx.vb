Imports System.Data

Partial Class PasswordForm
    Inherits System.Web.UI.UserControl

    Private Sub ShowFeedback(message As String, success As Boolean)
        litFeedbackTitle.Text = If(success, "Password updated", "Password could not be updated")
        Ui.Notice(litMessage, message, success)
        pnlFeedback.Visible = True
    End Sub

    Protected Sub btnChange_Click(sender As Object, e As EventArgs)
        If Not Auth.IsLoggedIn Then Return
        Dim row As DataRow = Db.QueryRow("SELECT password_hash FROM users WHERE user_id = @id", "@id", Auth.UserId)
        If row Is Nothing OrElse Not BCrypt.Net.BCrypt.Verify(txtCurrent.Text, CStr(row("password_hash"))) Then
            ShowFeedback("The current password is incorrect. Re-enter your current password and try again.", False)
            Return
        End If
        If Not Auth.PasswordIsStrong(txtNew.Text) Then
            ShowFeedback("Your new password needs at least 8 characters, including letters and numbers.", False)
            Return
        End If
        If txtNew.Text <> txtConfirm.Text Then
            ShowFeedback("The new password and confirmation do not match. Enter the same new password in both fields.", False)
            Return
        End If
        Dim changed As Integer = Db.Execute("UPDATE users SET password_hash = @hash, password_changed = NOW(), session_version = session_version + 1, date_modified = NOW() WHERE user_id = @id AND account_status = 'Active' AND password_hash = @current", "@hash", Auth.HashPassword(txtNew.Text), "@id", Auth.UserId, "@current", row("password_hash"))
        If changed > 0 Then
            ShowFeedback("Sign in again using your new password when prompted.", True)
        Else
            ShowFeedback("Your account changed while the form was open. Sign in again and retry.", False)
        End If
    End Sub

End Class
