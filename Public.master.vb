Partial Class PublicMaster
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim lastRun As Object = Application("HousekeepingAt")
        If lastRun Is Nothing OrElse DateTime.UtcNow - CType(lastRun, DateTime) > TimeSpan.FromMinutes(1) Then
            Db.Housekeeping()
            Application("HousekeepingAt") = DateTime.UtcNow
        End If

        Dim items As String(,) = {
            {"Dashboard", "~/Default.aspx"},
            {"Rankings", "~/Viewer/Rankings.aspx"},
            {"Announcements", "~/Viewer/Announcements.aspx"},
            {"Roster", "~/Viewer/Roster.aspx"},
            {"Calendar", "~/Viewer/Calendar.aspx"}
        }
        For i As Integer = 0 To items.GetLength(0) - 1
            Ui.AddNavLink(litNav, items(i, 0), items(i, 1))
        Next
        Ui.AddNavLink(litNav, "Admin Login", "~/Login.aspx")
    End Sub

End Class
