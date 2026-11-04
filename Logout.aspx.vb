Partial Class Logout
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Auth.SignOut()
        Response.Redirect("~/Login.aspx")
    End Sub

End Class
