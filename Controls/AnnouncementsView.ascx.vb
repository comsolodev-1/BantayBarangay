Imports System.Data

Partial Class AnnouncementsView
    Inherits System.Web.UI.UserControl

    Public Property MaxItems As Integer = 100

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim sql As String = "SELECT announcement_id, title, content, attachment_file_name, date_published, priority, is_pinned FROM announcements " &
            "WHERE status = 'Published' AND (expiration_date IS NULL OR expiration_date >= NOW()) AND (date_published IS NULL OR date_published <= NOW()) "
        Dim data As DataTable
        If Auth.IsLoggedIn AndAlso Not Auth.IsSuperAdmin Then
            sql &= "AND (visibility_type = 'All' OR (visibility_type = 'Specific Role' AND target_role = @role) OR (visibility_type = 'Specific Barangay' AND target_barangay_id = @barangay)) "
            sql &= "ORDER BY is_pinned DESC, date_published DESC LIMIT " & MaxItems
            data = Db.Query(sql, "@role", Auth.Role, "@barangay", Auth.BarangayId)
        Else
            sql &= "AND visibility_type = 'All' ORDER BY is_pinned DESC, date_published DESC LIMIT " & MaxItems
            data = Db.Query(sql)
        End If
        rptAnnouncements.DataSource = data
        rptAnnouncements.DataBind()
        If data.Rows.Count = 0 Then
            litEmpty.Text = "<div class=""card"">No announcements at the moment.</div>"
        End If
    End Sub

End Class
