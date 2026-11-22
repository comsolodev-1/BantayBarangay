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
                    .Text = Ui.H(row("title")),
                    .CssClass = If(CStr(row("kind")) = "Announcement", "calendar-event announcement-event", "calendar-event")
                }
                e.Cell.Controls.Add(eventLabel)
            End If
        Next
    End Sub

End Class
