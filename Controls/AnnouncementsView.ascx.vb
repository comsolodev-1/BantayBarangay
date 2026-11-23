Imports System.Data

Partial Class AnnouncementsView
    Inherits System.Web.UI.UserControl

    Public Property MaxItems As Integer

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then BindAnnouncements()
    End Sub

    Protected Sub Pager_PageChanged(sender As Object, e As EventArgs)
        BindAnnouncements()
    End Sub

    Private Sub BindAnnouncements()
        Const columns As String = "announcement_id, title, content, attachment_file_name, date_published, priority, is_pinned"
        Const orderBy As String = "is_pinned DESC, date_published DESC, announcement_id DESC"
        Dim source As String = "FROM announcements " &
            "WHERE status = 'Published' AND (expiration_date IS NULL OR expiration_date >= NOW()) AND (date_published IS NULL OR date_published <= NOW()) "
        Dim args As Object() = New Object() {}
        If Auth.IsLoggedIn AndAlso Not Auth.IsSuperAdmin Then
            source &= "AND (visibility_type = 'All' OR (visibility_type = 'Specific Role' AND target_role_id = (SELECT role_id FROM roles WHERE role_name = @role)) OR (visibility_type = 'Specific Barangay' AND target_barangay_code = @barangay))"
            args = New Object() {"@role", Auth.Role, "@barangay", Auth.BarangayCode}
        Else
            source &= "AND visibility_type = 'All'"
        End If
        Dim data As DataTable = If(MaxItems > 0,
                                   Db.Query("SELECT " & columns & " " & source & " ORDER BY " & orderBy & " LIMIT " & MaxItems, args),
                                   pager.ReadPage(columns, source, orderBy, args))
        rptAnnouncements.DataSource = data
        rptAnnouncements.DataBind()
        emptyCard.Visible = data.Rows.Count = 0
        If data.Rows.Count = 0 Then
            litEmpty.Text = "<p>No announcements at the moment.</p>"
        End If
    End Sub

End Class
