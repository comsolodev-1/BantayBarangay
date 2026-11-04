Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class CalendarData

    Public Shared Function ForMonth(year As Integer, month As Integer, publicOnly As Boolean) As DataTable
        Dim dateFilter As String = If(publicOnly, " AND visibility_type = 'All'", "")
        Dim activityFilter As String = If(publicOnly, " AND a.is_public = 1", "")
        Dim sql As String = "SELECT event_date AS event_day, title, event_type AS kind FROM important_dates WHERE YEAR(event_date) = @year AND MONTH(event_date) = @month" & dateFilter &
            " UNION ALL SELECT DATE(p.submission_deadline) AS event_day, CONCAT(a.activity_name, ' (deadline)') AS title, 'Deadline' AS kind FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
            "WHERE YEAR(p.submission_deadline) = @year AND MONTH(p.submission_deadline) = @month AND a.activity_status <> 'Archived'" & activityFilter &
            " ORDER BY event_day, title"
        Return Db.Query(sql, "@year", year, "@month", month)
    End Function

End Class
