Partial Class Viewer_Roster
    Inherits PublicPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlBarangay, Db.Query("SELECT barangay_id, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_id")
        BindRoster()
    End Sub

    Private Sub BindRoster()
        If ddlBarangay.Items.Count = 0 Then Return
        gvRoster.DataSource = Db.Query("SELECT CONCAT(first_name, ' ', COALESCE(CONCAT(LEFT(middle_name, 1), '. '), ''), last_name, COALESCE(CONCAT(' ', suffix), '')) AS full_name, position, committee FROM barangay_roster WHERE barangay_id = @id AND status = 'Active' ORDER BY last_name, first_name", "@id", CInt(ddlBarangay.SelectedValue))
        gvRoster.DataBind()
    End Sub

    Protected Sub ddlBarangay_SelectedIndexChanged(sender As Object, e As EventArgs)
        BindRoster()
    End Sub

End Class
