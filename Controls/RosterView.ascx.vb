Partial Class RosterView
    Inherits System.Web.UI.UserControl

    Public Property AllowChanges As Boolean
    Public Event RowCommand As GridViewCommandEventHandler

    Public Sub BindRoster(barangayCode As String, Optional search As String = "", Optional publicOnly As Boolean = False)
        gvRoster.Columns(gvRoster.Columns.Count - 1).Visible = AllowChanges
        Dim sql As String = "SELECT r.roster_id, r.photo_path, b.barangay_name, " &
            "CONCAT_WS(' ', r.first_name, NULLIF(r.middle_name, ''), r.last_name, NULLIF(r.suffix, '')) AS full_name, " &
            "r.position, r.committee, CONCAT(r.term_start_year, '-', r.term_end_year) AS term_of_service, r.status " &
            "FROM barangay_roster r JOIN barangays b ON b.barangay_code = r.barangay_code " &
            "WHERE (@barangay = '' OR r.barangay_code = @barangay) " &
            "AND (CONCAT_WS(' ', r.first_name, r.middle_name, r.last_name, r.suffix) LIKE @search OR " &
            "CONCAT_WS(' ', r.first_name, r.last_name) LIKE @search OR r.position LIKE @search) "
        If publicOnly Then sql &= "AND b.status = 'Active' AND r.status = 'Active' "
        gvRoster.DataSource = Db.Query(sql & "ORDER BY b.barangay_name, r.last_name, r.first_name, r.roster_id",
                                      "@barangay", barangayCode, "@search", "%" & search & "%")
        gvRoster.DataBind()
    End Sub

    Protected Sub gvRoster_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        If AllowChanges Then RaiseEvent RowCommand(Me, e)
    End Sub
End Class
