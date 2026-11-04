Imports System.Text

Partial Class SiteMaster
    Inherits System.Web.UI.MasterPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim lastRun As Object = Application("HousekeepingAt")
        If lastRun Is Nothing OrElse DateTime.UtcNow - CType(lastRun, DateTime) > TimeSpan.FromMinutes(1) Then
            Db.Housekeeping()
            Application("HousekeepingAt") = DateTime.UtcNow
        End If

        litName.Text = Ui.H(Auth.FullName)
        If Auth.IsSuperAdmin Then
            litRole.Text = "Super Admin"
        Else
            litRole.Text = "Barangay Admin - " & Ui.H(Auth.BarangayName)
        End If
        litTitle.Text = Ui.H(Page.Title)
        litToday.Text = DateTime.Now.ToString("dddd, MMMM d, yyyy")
        BuildMenu()
    End Sub

    Private Sub BuildMenu()
        Dim folder As String = If(Auth.IsSuperAdmin, "Super", "Barangay")
        Dim items As New List(Of String())
        items.Add(New String() {"Dashboard", "Dashboard.aspx"})
        If Auth.IsSuperAdmin Then
            items.Add(New String() {"Activities", "Activities.aspx"})
            items.Add(New String() {"Submissions", "Submissions.aspx"})
            items.Add(New String() {"Reports", "Reports.aspx"})
            items.Add(New String() {"Rankings", "Rankings.aspx"})
            items.Add(New String() {"Announcements", "Announcements.aspx"})
            items.Add(New String() {"Important Dates", "ImportantDates.aspx"})
            items.Add(New String() {"Accounts", "Accounts.aspx"})
        Else
            items.Add(New String() {"My Activities", "MyActivities.aspx"})
            items.Add(New String() {"My Reports", "MyReports.aspx"})
            items.Add(New String() {"Officials & Roster", "Roster.aspx"})
            items.Add(New String() {"Rankings", "Rankings.aspx"})
            items.Add(New String() {"Announcements", "Announcements.aspx"})
        End If

        Dim currentPath As String = Request.Url.AbsolutePath.ToLowerInvariant()
        Dim html As New StringBuilder()
        For Each item As String() In items
            Dim target As String = ResolveUrl("~/" & folder & "/" & item(1))
            Dim css As String = ""
            If currentPath.EndsWith("/" & item(1).ToLowerInvariant()) Then css = " class=""active"""
            html.Append("<a href=""" & target & """" & css & ">" & Ui.H(item(0)) & "</a>")
        Next
        litMenu.Text = html.ToString()

        Dim settingsCss As String = ""
        If currentPath.EndsWith("/settings.aspx") Then settingsCss = " class=""active"""
        litSettings.Text = "<a href=""" & ResolveUrl("~/" & folder & "/Settings.aspx") & """" & settingsCss & ">Settings</a>"
    End Sub

    Protected Sub btnSignOut_Click(sender As Object, e As EventArgs)
        Auth.SignOut()
        Response.Redirect("~/Login.aspx")
    End Sub

End Class
