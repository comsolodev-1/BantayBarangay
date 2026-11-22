Partial Class Viewer_Roster
    Inherits PublicPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlBarangay, Db.Query("SELECT barangay_code, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_code")
        BindRoster()
    End Sub

    Private Sub BindRoster()
        If ddlBarangay.Items.Count = 0 Then Return
        roster.BindRoster(ddlBarangay.SelectedValue, publicOnly:=True)
    End Sub

    Protected Sub ddlBarangay_SelectedIndexChanged(sender As Object, e As EventArgs)
        BindRoster()
    End Sub

End Class
