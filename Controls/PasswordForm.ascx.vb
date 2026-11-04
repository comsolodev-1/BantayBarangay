Imports System.Data

Partial Class PasswordForm
    Inherits System.Web.UI.UserControl

    Protected Sub btnChange_Click(sender As Object, e As EventArgs)
        If Not Auth.IsLoggedIn Then Return
        Dim row As DataRow = Db.QueryRow("SELECT password_hash FROM users WHERE user_id = @id", "@id", Auth.UserId)
        If row Is Nothing OrElse Not BCrypt.Net.BCrypt.Verify(txtCurrent.Text, CStr(row("password_hash"))) Then
            Ui.Notice(litMessage, "Current password is incorrect.", False)
            Return
        End If
        If txtNew.Text <> txtConfirm.Text Then
            Ui.Notice(litMessage, "New password and confirmation do not match.", False)
            Return
        End If
        If Not Auth.PasswordIsStrong(txtNew.Text) Then
            Ui.Notice(litMessage, "New password must be at least 8 characters and include letters and numbers.", False)
            Return
        End If
        Db.Execute("UPDATE users SET password_hash = @hash, password_changed = NOW(), date_modified = NOW() WHERE user_id = @id", "@hash", Auth.HashPassword(txtNew.Text), "@id", Auth.UserId)
        txtCurrent.Text = ""
        Ui.Notice(litMessage, "Password updated.", True)
    End Sub

End Class
