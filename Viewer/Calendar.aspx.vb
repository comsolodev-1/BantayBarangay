Imports System.Data

Partial Class Viewer_Calendar
    Inherits PublicPage

    Private monthEvents As DataTable

    Protected Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        Dim month As DateTime = If(calEvents.VisibleDate = DateTime.MinValue, calEvents.TodaysDate, calEvents.VisibleDate)
        monthEvents = CalendarData.ForMonth(month.Year, month.Month, True)
    End Sub

    Protected Sub calEvents_DayRender(sender As Object, e As DayRenderEventArgs)
        If monthEvents Is Nothing OrElse e.Day.IsOtherMonth Then Return
        For Each row As DataRow In monthEvents.Rows
            If Convert.ToDateTime(row("event_day")).Date = e.Day.Date.Date Then
                Dim eventLabel As New Label With {
                    .Text = Ui.H(row("title"))
                }
                Dim isAnnouncement As Boolean = CStr(row("kind")) = "Announcement"
                eventLabel.BackColor = Drawing.ColorTranslator.FromHtml(If(isAnnouncement, "#fff1cb", "#e6f2ec"))
                eventLabel.ForeColor = Drawing.ColorTranslator.FromHtml(If(isAnnouncement, "#594000", "#193e2a"))
                eventLabel.Font.Size = FontUnit.Point(9)
                eventLabel.Style("display") = "block"
                eventLabel.Style("margin") = "2px 0"
                eventLabel.Style("padding") = "2px 4px"
                e.Cell.Controls.Add(eventLabel)
            End If
        Next
    End Sub

End Class
