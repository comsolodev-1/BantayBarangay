Partial Class Super_BarangayRoster
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlBarangay,
                Db.Query("SELECT barangay_code, barangay_name FROM barangays ORDER BY barangay_name"),
                "barangay_name", "barangay_code")
        ddlBarangay.Items.Insert(0, New ListItem("All barangays", ""))
        BindRoster()
    End Sub

    Protected Sub FilterChanged(sender As Object, e As EventArgs)
        BindRoster(resetPage:=True)
    End Sub

    Private Sub BindRoster(Optional resetPage As Boolean = False)
        roster.BindRoster(ddlBarangay.SelectedValue, txtSearch.Text.Trim(), resetPage:=resetPage)
    End Sub
End Class
