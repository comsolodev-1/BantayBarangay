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
            {"Dashboard", "~/Default.aspx"},
            {"Rankings", "~/Viewer/Rankings.aspx"},
            {"Announcements", "~/Viewer/Announcements.aspx"},
            {"Roster", "~/Viewer/Roster.aspx"},
            {"Calendar", "~/Viewer/Calendar.aspx"}
        }
        Dim navigation As New Table With {.CellPadding = 0, .CellSpacing = 0,
                                          .HorizontalAlign = HorizontalAlign.Right}
        navigation.Attributes("role") = "presentation"
        navigation.Rows.Add(New TableRow())
        litNav.Controls.Add(navigation)
        For i As Integer = 0 To items.GetLength(0) - 1
            AddHeaderLink(navigation, items(i, 0), items(i, 1), False)
        Next
        AddHeaderLink(navigation, "Admin Login", "~/Login.aspx", True)
    End Sub

    Private Sub AddHeaderLink(navigation As Table, caption As String, url As String, login As Boolean)
        Dim active As Boolean = String.Equals(Request.Url.AbsolutePath, ResolveUrl(url), StringComparison.OrdinalIgnoreCase)
        Dim link As New BarangayLayout.HeaderLink With {
            .Text = Ui.H(caption), .NavigateUrl = url, .EnableTheming = False,
            .ForeColor = If(login, Drawing.ColorTranslator.FromHtml("#1A3D28"), Drawing.Color.White),
            .Filled = active OrElse login,
            .SurfaceColor = If(login, Drawing.Color.White, Drawing.ColorTranslator.FromHtml("#1A5C38"))}
        link.Font.Underline = False
        link.Font.Size = FontUnit.Point(10)
        If active Then link.Attributes("aria-current") = "page"
        Dim cell As New TableCell With {.VerticalAlign = VerticalAlign.Middle, .HorizontalAlign = HorizontalAlign.Center,
                                       .Wrap = False}
        cell.Controls.Add(link)
        Dim row As TableRow = navigation.Rows(navigation.Rows.Count - 1)
        If Request.Browser.IsMobileDevice AndAlso row.Cells.Count >= 5 Then
            row = New TableRow()
            navigation.Rows.Add(row)
        End If
        If row.Cells.Count > 0 Then row.Cells.Add(BarangayLayout.FieldRow.Spacer(16))
        row.Cells.Add(cell)
    End Sub
End Class
