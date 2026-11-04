Imports System.Data

Partial Class Viewer_Calendar
    Inherits PublicPage

    Private monthEvents As DataTable

    Protected Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        monthEvents = CalendarData.ForMonth(calEvents.VisibleDate.Year, calEvents.VisibleDate.Month, True)
    End Sub

    Protected Sub calEvents_DayRender(sender As Object, e As DayRenderEventArgs)
        If monthEvents Is Nothing OrElse e.Day.IsOtherMonth Then Return
        For Each row As DataRow In monthEvents.Rows
            If Convert.ToDateTime(row("event_day")).Date = e.Day.Date.Date Then
                e.Cell.Controls.Add(New LiteralControl("<span class=""ev"">" & Ui.H(row("title")) & "</span>"))
            End If
        Next
    End Sub

End Class
