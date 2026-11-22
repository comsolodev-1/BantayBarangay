Partial Class PublicMaster
    Inherits System.Web.UI.MasterPage

    Protected Overrides Sub OnInit(e As EventArgs)
        MyBase.OnInit(e)
        If Request.Browser.IsMobileDevice Then
            headerRow.Cells.Remove(navigationCell)
            navigationCell.ColumnSpan = 2
            mobileNavRow.Cells.Add(navigationCell)
            mobileNavRow.Visible = True
        End If
    End Sub

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim lastRun As Object = Application("HousekeepingAt")
        If lastRun Is Nothing OrElse DateTime.UtcNow - CType(lastRun, DateTime) > TimeSpan.FromMinutes(1) Then
            Db.Housekeeping()
            Application("HousekeepingAt") = DateTime.UtcNow
        End If

        Dim items As String(,) = {
            {"Dashboard", "~/Viewer/Dashboard.aspx"},
            {"Rankings", "~/Viewer/Rankings.aspx"},
            {"Announcements", "~/Viewer/Announcements.aspx"},
            {"Roster", "~/Viewer/Roster.aspx"},
            {"Calendar", "~/Viewer/Calendar.aspx"}
        }
        Dim navigation As New Panel()
        navigation.Style("display") = "flex"
        navigation.Style("flex-wrap") = "wrap"
        navigation.Style("align-items") = "center"
        navigation.Style("justify-content") = "flex-end"
        navigation.Style("gap") = "6px 16px"
        litNav.Controls.Add(navigation)
        For i As Integer = 0 To items.GetLength(0) - 1
            AddHeaderLink(navigation, items(i, 0), items(i, 1), False)
        Next
        AddHeaderLink(navigation, "Exit", "~/Logout.aspx", True)
    End Sub

    Private Sub AddHeaderLink(navigation As Panel, caption As String, url As String, highlight As Boolean)
        Dim active As Boolean = String.Equals(Request.Url.AbsolutePath, ResolveUrl(url), StringComparison.OrdinalIgnoreCase)
        Dim link As New BarangayLayout.HeaderLink With {
            .Text = Ui.H(caption), .NavigateUrl = url, .EnableTheming = False,
            .ForeColor = If(highlight, Drawing.ColorTranslator.FromHtml("#1A3D28"), Drawing.Color.White),
            .Filled = active OrElse highlight,
            .SurfaceColor = If(highlight, Drawing.Color.White, Drawing.ColorTranslator.FromHtml("#1A5C38"))}
        link.Font.Underline = False
        link.Font.Size = FontUnit.Point(10)
        If highlight Then
            link.Style("min-width") = "72px"
            link.Style("text-align") = "center"
        End If
        If active Then link.Attributes("aria-current") = "page"
        navigation.Controls.Add(link)
    End Sub
End Class
