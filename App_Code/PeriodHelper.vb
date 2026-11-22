Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Globalization
Imports System.Web
Imports MySql.Data.MySqlClient

Public Class PeriodHelper

    Public Shared ReadOnly Frequencies As String() = {"Weekly", "Monthly", "Quarterly", "Annual", "General"}
    Public Const DefaultGraceDays As Integer = 7
    Public Const MaximumGraceDays As Integer = 365
    Public Const MaximumRangeMonths As Integer = 120
    Public Const CutoffSql As String = "DATE_ADD(p.submission_deadline, INTERVAL p.grace_days DAY)"
    Public Const AcceptsSubmissionSql As String = "p.submission_deadline IS NOT NULL AND NOW() <= " & CutoffSql
    Public Const StatusSql As String = "CASE WHEN a.activity_status = 'Archived' THEN 'Archived' WHEN p.submission_deadline IS NULL THEN 'Awaiting Deadline' WHEN NOW() <= p.submission_deadline THEN 'Open' WHEN NOW() <= " & CutoffSql & " THEN 'Grace Period' ELSE 'Closed' END"

    Private Shared Function WeekThursday(value As DateTime) As DateTime
        Return value.Date.AddDays(3 - ((CInt(value.DayOfWeek) + 6) Mod 7))
    End Function

    Public Shared Function NameFor(frequency As String, deadline As DateTime) As String
        Select Case frequency
            Case "Weekly"
                Return "Week " & NumberFor(frequency, deadline).ToString() & " " & WeekThursday(deadline).Year
            Case "Monthly"
                Return deadline.ToString("MMMM yyyy")
            Case "Quarterly"
                Return "Q" & ((deadline.Month - 1) \ 3 + 1) & " " & deadline.Year
            Case "Annual"
                Return deadline.Year.ToString()
        End Select
        Return "General - " & deadline.ToString("MMM d, yyyy", CultureInfo.InvariantCulture)
    End Function

    Public Shared Function NumberFor(frequency As String, deadline As DateTime) As Object
        Select Case frequency
            Case "Weekly"
                Return CultureInfo.InvariantCulture.Calendar.GetWeekOfYear(WeekThursday(deadline), CalendarWeekRule.FirstFourDayWeek, DayOfWeek.Monday)
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

    Public Shared Sub CreateInTransaction(tx As MySqlTransaction, activityId As Long, frequency As String, periodDate As DateTime, deadline As Object, graceDays As Integer, userId As Object)
        Dim startDate As DateTime
        Dim endDate As DateTime
        RangeFor(frequency, periodDate, startDate, endDate)
        Dim year As Integer = If(frequency = "Weekly", WeekThursday(periodDate).Year, periodDate.Year)
        Db.TxExecute(tx, "INSERT INTO reporting_period (activity_id, period_type, period_name, period_year, period_number, start_date, end_date, submission_deadline, grace_days, period_status, date_opened, created_by) " &
                     "VALUES (@a, @type, @name, @year, @number, @start, @end, @deadline, @grace, IF(@deadline IS NULL, 'Awaiting Deadline', 'Open'), IF(@deadline IS NULL, NULL, NOW()), @user)",
                     "@a", activityId, "@type", frequency, "@name", NameFor(frequency, periodDate), "@year", year, "@number", NumberFor(frequency, periodDate),
                     "@start", startDate, "@end", endDate, "@deadline", deadline, "@grace", graceDays, "@user", userId)
    End Sub

    Public Shared Function ContainsPeriod(tx As MySqlTransaction, activityId As Integer, startDate As DateTime, endDate As DateTime) As Boolean
        Return Db.TxScalar(tx, "SELECT period_id FROM reporting_period WHERE activity_id = @id AND start_date BETWEEN @start AND @end LIMIT 1",
                           "@id", activityId, "@start", startDate, "@end", endDate) IsNot Nothing
    End Function

    Public Shared Sub SaveDeadline(tx As MySqlTransaction, periodId As Integer, deadline As DateTime, graceDays As Integer)
        Db.TxExecute(tx, "UPDATE reporting_period SET submission_deadline = @deadline, grace_days = @grace, date_opened = COALESCE(date_opened, NOW()), " &
                     "period_status = CASE WHEN NOW() <= @deadline THEN 'Open' WHEN NOW() <= DATE_ADD(@deadline, INTERVAL @grace DAY) THEN 'Grace Period' ELSE 'Closed' END, " &
                     "date_closed = IF(NOW() > DATE_ADD(@deadline, INTERVAL @grace DAY), DATE_ADD(@deadline, INTERVAL @grace DAY), NULL), date_modified = NOW() WHERE period_id = @id",
                     "@deadline", deadline, "@grace", graceDays, "@id", periodId)
        Db.TxExecute(tx, "UPDATE submissions SET is_late = date_submitted > @deadline, score = IF(submission_status = 'Confirmed', IF(date_submitted > @deadline, @late, @onTime), score), " &
                     "date_modified = NOW() WHERE period_id = @id AND is_late <> (date_submitted > @deadline)",
                     "@deadline", deadline, "@late", Scoring.LateScore, "@onTime", Scoring.OnTimeScore, "@id", periodId)
    End Sub

    Public Shared Sub EnsureScheduledPeriods()
        Dim context As HttpContext = HttpContext.Current
        If context.Items("ScheduledPeriodsChecked") IsNot Nothing Then Return
        Dim housekeeping As Object = context.Items("Housekeeping")
        context.Items("Housekeeping") = True
        Try
            Dim activities As DataTable = Db.Query("SELECT activity_id FROM activities WHERE activity_status <> 'Archived' AND frequency_range_months > 0 " &
                                                   "AND next_period_start <= CURDATE() AND next_period_start < DATE_ADD(DATE(date_created), INTERVAL frequency_range_months MONTH)")
            For Each item As DataRow In activities.Rows
                Dim activityId As Integer = CInt(item("activity_id"))
                Db.InTransaction(Sub(tx)
                    Dim row As DataRow = Db.TxRow(tx, "SELECT frequency, next_period_start, CURDATE() AS today, DATE_ADD(DATE(date_created), INTERVAL frequency_range_months MONTH) AS range_end " &
                                                  "FROM activities WHERE activity_id = @id AND activity_status <> 'Archived' AND frequency_range_months > 0 AND next_period_start IS NOT NULL FOR UPDATE", "@id", activityId)
                    If row Is Nothing Then Return
                    Dim start As DateTime = CDate(row("next_period_start"))
                    Dim through As DateTime = CDate(row("range_end")).AddDays(-1)
                    If CDate(row("today")) < through Then through = CDate(row("today"))
                    If start > through Then Return
                    Dim frequency As String = CStr(row("frequency"))
                    If frequency = "General" Then Return
                    While start <= through
                        Dim cycleStart As DateTime
                        Dim cycleEnd As DateTime
                        RangeFor(frequency, start, cycleStart, cycleEnd)
                        If Not ContainsPeriod(tx, activityId, cycleStart, cycleEnd) Then
                            CreateInTransaction(tx, activityId, frequency, cycleStart, Nothing, DefaultGraceDays, Nothing)
                        End If
                        start = cycleEnd.AddDays(1)
                    End While
                    Db.TxExecute(tx, "UPDATE activities SET next_period_start = @start WHERE activity_id = @id", "@start", start, "@id", activityId)
                End Sub)
            Next
            context.Items("ScheduledPeriodsChecked") = True
        Finally
            context.Items("Housekeeping") = housekeeping
        End Try
    End Sub

    Public Shared Function PendingDeadlineCount() As Integer
        Return Db.ScalarInt("SELECT COUNT(*) FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
                            "WHERE p.submission_deadline IS NULL AND a.activity_status <> 'Archived'")
    End Function

End Class
