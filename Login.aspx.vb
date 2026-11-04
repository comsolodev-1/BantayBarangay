Partial Class Login
    Inherits PublicPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        If Auth.IsLoggedIn Then Response.Redirect(Auth.HomeUrl())
        If Request.QueryString("expired") = "1" Then
            Ui.Notice(litMessage, "Please sign in to continue.", False)
        End If
    End Sub

    Protected Sub btnLogin_Click(sender As Object, e As EventArgs)
        If txtWebsite.Text.Length > 0 Then
            Threading.Thread.Sleep(1500)
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
            txtPassword.Text = ""
            Ui.Notice(litMessage, message, False)
        End If
    End Sub

End Class
