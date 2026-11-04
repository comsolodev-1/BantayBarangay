Imports System.Text

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
        Dim currentPath As String = Request.Url.AbsolutePath.ToLowerInvariant()
        Dim html As New StringBuilder()
        For i As Integer = 0 To items.GetLength(0) - 1
            Dim target As String = ResolveUrl(items(i, 1))
            Dim css As String = ""
            If currentPath = target.ToLowerInvariant() Then css = " class=""active"""
            html.Append("<a href=""" & target & """" & css & ">" & Ui.H(items(i, 0)) & "</a>")
        Next
        html.Append("<a class=""login"" href=""" & ResolveUrl("~/Login.aspx") & """>Admin Login</a>")
        litNav.Text = html.ToString()
    End Sub

End Class
