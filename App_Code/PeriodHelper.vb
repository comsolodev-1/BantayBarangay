Imports System
Imports System.Collections.Generic
Imports System.Globalization
Imports MySql.Data.MySqlClient

Public Class PeriodHelper

    Public Shared ReadOnly Frequencies As String() = {"Weekly", "Monthly", "Quarterly", "Annual", "General"}

    Private Shared Function WeekNumber(value As DateTime) As Integer
        Return CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(value, CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday)
    End Function

    Public Shared Function NameFor(frequency As String, deadline As DateTime) As String
        Select Case frequency
            Case "Weekly"
                Return "Week " & WeekNumber(deadline) & " " & deadline.Year
            Case "Monthly"
                Return deadline.ToString("MMMM yyyy")
            Case "Quarterly"
                Return "Q" & ((deadline.Month - 1) \ 3 + 1) & " " & deadline.Year
            Case "Annual"
                Return deadline.Year.ToString()
        End Select
        Return "General"
    End Function

    Public Shared Function NumberFor(frequency As String, deadline As DateTime) As Object
        Select Case frequency
            Case "Weekly"
                Return CInt(Math.Min(WeekNumber(deadline), 53))
            Case "Monthly"
                Return deadline.Month
            Case "Quarterly"
                Return (deadline.Month - 1) \ 3 + 1
        End Select
        Return Nothing
    End Function

    Public Shared Sub RangeFor(frequency As String, deadline As DateTime, ByRef startDate As DateTime, ByRef endDate As DateTime)
        Dim day As DateTime = deadline.Date
        Select Case frequency
            Case "Weekly"
                startDate = day.AddDays(-((CInt(day.DayOfWeek) + 6) Mod 7))
                endDate = startDate.AddDays(6)
            Case "Monthly"
                startDate = New DateTime(day.Year, day.Month, 1)
                endDate = startDate.AddMonths(1).AddDays(-1)
            Case "Quarterly"
                Dim firstMonth As Integer = ((day.Month - 1) \ 3) * 3 + 1
                startDate = New DateTime(day.Year, firstMonth, 1)
                endDate = startDate.AddMonths(3).AddDays(-1)
            Case "Annual"
                startDate = New DateTime(day.Year, 1, 1)
                endDate = New DateTime(day.Year, 12, 31)
            Case Else
                startDate = day
                endDate = day
        End Select
    End Sub

    Public Shared Function EndOfDay(value As DateTime) As DateTime
        Return value.Date.AddHours(23).AddMinutes(59).AddSeconds(59)
    End Function

    Public Shared Sub CreateInTransaction(tx As MySqlTransaction, activityId As Long, frequency As String, deadline As DateTime, userId As Integer)
        Dim startDate As DateTime
        Dim endDate As DateTime
        RangeFor(frequency, deadline, startDate, endDate)
        Db.TxExecute(tx, "INSERT INTO reporting_period (activity_id, period_type, period_name, period_year, period_number, start_date, end_date, submission_deadline, period_status, date_opened, created_by) VALUES (@a, @type, @name, @year, @number, @start, @end, @deadline, 'Open', NOW(), @user)",
                     "@a", activityId, "@type", frequency, "@name", NameFor(frequency, deadline), "@year", deadline.Year, "@number", NumberFor(frequency, deadline), "@start", startDate, "@end", endDate, "@deadline", EndOfDay(deadline), "@user", userId)
    End Sub

End Class
