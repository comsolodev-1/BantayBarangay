Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class CalendarData

    Public Shared Function ForMonth(year As Integer, month As Integer, publicOnly As Boolean) As DataTable
        Dim dateFilter As String = If(publicOnly, " AND visibility_type = 'All'", "")
        Dim isBarangay As Boolean = Not publicOnly AndAlso Auth.IsLoggedIn AndAlso Auth.Role = Auth.BarangayAdminRole
        If isBarangay Then
            dateFilter = " AND (visibility_type = 'All' OR (visibility_type = 'Specific Role' AND target_role_id = (SELECT role_id FROM roles WHERE role_name = @role)) OR (visibility_type = 'Specific Barangay' AND (target_barangay_code = @barangay)))"
        End If
        Dim activityFilter As String = If(publicOnly, " AND a.is_public = 1", "")
        If isBarangay Then
            activityFilter = " AND EXISTS (SELECT 1 FROM activity_barangays ab WHERE ab.activity_id = a.activity_id AND ab.barangay_code = @barangay)"
        End If
        Dim sql As String = "SELECT event_date AS event_day, title, event_type AS kind FROM important_dates WHERE YEAR(event_date) = @year AND MONTH(event_date) = @month" & dateFilter &
            " UNION ALL SELECT DATE(p.submission_deadline) AS event_day, CONCAT(a.activity_name, ' (deadline)') AS title, 'Deadline' AS kind FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
            "WHERE YEAR(p.submission_deadline) = @year AND MONTH(p.submission_deadline) = @month AND a.activity_status <> 'Archived'" & activityFilter &
            " ORDER BY event_day, title"
        Return Db.Query(sql, "@year", year, "@month", month, "@role", Auth.Role, "@barangay", Auth.BarangayCode)
    End Function

End Class
