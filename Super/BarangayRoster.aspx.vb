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
        BindRoster()
    End Sub

    Private Sub BindRoster()
        gvRoster.DataSource = Db.Query(
            "SELECT b.barangay_name, CONCAT_WS(' ', r.first_name, NULLIF(r.middle_name, ''), r.last_name, NULLIF(r.suffix, '')) AS full_name, " &
            "r.position, r.committee, r.status FROM barangay_roster r JOIN barangays b ON b.barangay_code = r.barangay_code " &
            "WHERE (@barangay = '' OR r.barangay_code = @barangay) " &
            "AND (CONCAT_WS(' ', r.first_name, r.middle_name, r.last_name, r.suffix) LIKE @search OR " &
            "CONCAT_WS(' ', r.first_name, r.last_name) LIKE @search OR r.position LIKE @search) " &
            "ORDER BY b.barangay_name, r.last_name, r.first_name",
            "@barangay", ddlBarangay.SelectedValue, "@search", "%" & txtSearch.Text.Trim() & "%")
        gvRoster.DataBind()
    End Sub
End Class
