Partial Class Login
    Inherits PublicPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Response.Cache.SetNoStore()
        If IsPostBack Then Return
        If Request.QueryString("signedout") = "1" Then
            txtUsername.Text = ""
            txtPassword.Text = ""
            txtUsername.Attributes("autocomplete") = "off"
            txtPassword.Attributes("autocomplete") = "off"
        End If
        If Auth.IsLoggedIn Then Response.Redirect(Auth.HomeUrl())
        If Auth.LoginLockSeconds() > 0 Then
            Ui.Notice(litMessage, Auth.LockMessage(), False)
            form1.Attributes("data-lock-seconds") = Auth.LoginLockSeconds().ToString()
        End If
        If Request.QueryString("expired") = "1" Then
            Ui.Notice(litMessage, "Please sign in to continue.", False)
        End If
    End Sub

    Protected Sub btnLogin_Click(sender As Object, e As EventArgs)
        If txtWebsite.Text.Length > 0 Then
            Threading.Thread.Sleep(1500)
            txtUsername.Text = ""
            txtPassword.Text = ""
            Ui.Notice(litMessage, "Invalid username or password.", False)
            Return
        End If
        If txtUsername.Text.Trim().Length = 0 OrElse txtPassword.Text.Length = 0 Then
            Ui.Notice(litMessage, "Please enter your username and password.", False)
            Return
        End If
        Dim message As String = ""
        If Auth.SignIn(txtUsername.Text, txtPassword.Text, message) Then
            Response.Redirect(Auth.HomeUrl())
        Else
            txtUsername.Text = ""
            txtPassword.Text = ""
            Ui.Notice(litMessage, message, False)
            If Auth.LockSeconds > 0 Then form1.Attributes("data-lock-seconds") = Auth.LockSeconds.ToString()
        End If
    End Sub

End Class
