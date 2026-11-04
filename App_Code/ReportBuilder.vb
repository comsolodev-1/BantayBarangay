Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class ReportResult
    Public Title As String
    Public Subtitle As String
    Public Table As DataTable
    Public Notes As New List(Of String)
End Class

Public Class ReportBuilder

    Public Shared ReadOnly Keys As String(,) = {
        {"weekly", "1. Weekly Activity Report Submission Summary"},
        {"monthly", "2. Monthly Activity Report Submission Summary"},
        {"quarterly", "3. Quarterly Activity Report Submission Summary"},
        {"ranking", "4. Barangay Ranking Report"},
        {"roster", "5. Barangay Roster Report"},
        {"calendar", "6. Monthly Calendar Activity Report"},
        {"announcements", "7. Announcement Report"},
        {"late", "8. Late Barangay Activity Submission Report"},
        {"nonsubmission", "9. Barangay Non-Submission Report"},
        {"reportcard", "10. Individual Barangay Report Card"}
    }

    Private Shared Function MonthLabel(year As Integer, month As Integer) As String
        Return New DateTime(year, month, 1).ToString("MMMM yyyy")
    End Function

    Public Shared Function ActivitySummary(periodId As Integer, frequencyTitle As String) As ReportResult
        Dim info As DataRow = Db.QueryRow("SELECT a.activity_id, a.activity_name, p.period_name, p.submission_deadline FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id WHERE p.period_id = @p", "@p", periodId)
        Dim result As New ReportResult()
        result.Title = frequencyTitle & " Activity Report Submission Summary"
        If info Is Nothing Then
            result.Subtitle = "No activity selected."
            result.Table = New DataTable()
            Return result
        End If
        result.Subtitle = CStr(info("activity_name")) & " - " & CStr(info("period_name")) & " (deadline " & Ui.DateText(info("submission_deadline")) & ")"
        result.Table = Db.Query("SELECT b.barangay_name AS `Barangay`, COALESCE(s.submission_status, 'Not Submitted') AS `Status`, COALESCE(DATE_FORMAT(s.date_submitted, '%b %e, %Y'), '-') AS `Date Submitted`, IF(s.date_id IS NULL, '-', IF(s.is_late = 1, 'Yes', 'No')) AS `Late`, COALESCE(CAST(s.score AS CHAR), '-') AS `Score` " &
            "FROM barangays b JOIN activity_barangays ab ON ab.barangay_id = b.barangay_id AND ab.activity_id = @a " &
            "LEFT JOIN submissions s ON s.barangay_id = b.barangay_id AND s.period_id = @p WHERE b.status = 'Active' ORDER BY b.barangay_name", "@a", CInt(info("activity_id")), "@p", periodId)
        Dim confirmed As Integer = 0
        Dim pending As Integer = 0
        Dim denied As Integer = 0
        Dim missing As Integer = 0
        For Each row As DataRow In result.Table.Rows
            Select Case CStr(row("Status"))
                Case "Confirmed" : confirmed += 1
                Case "Pending" : pending += 1
                Case "Denied" : denied += 1
                Case Else : missing += 1
            End Select
        Next
        result.Notes.Add("Confirmed: " & confirmed & "   Pending: " & pending & "   Denied: " & denied & "   Not submitted: " & missing)
        Return result
    End Function

    Public Shared Function Ranking(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Barangay Ranking Report"
        result.Subtitle = If(month > 0, MonthLabel(year, month), "Year " & year)
        Dim source As DataTable = Scoring.Ranking(year, month)
        source.Columns.Remove("barangay_id")
        result.Table = source
        result.Notes.Add("Scores: confirmed on-time report = 1.0, confirmed late report = 0.5.")
        Return result
    End Function

    Public Shared Function Roster(barangayId As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Barangay Roster Report"
        result.Subtitle = If(barangayId > 0, "Selected barangay", "All barangays")
        Dim sql As String = "SELECT b.barangay_name AS `Barangay`, CONCAT(r.first_name, ' ', COALESCE(CONCAT(LEFT(r.middle_name, 1), '. '), ''), r.last_name, COALESCE(CONCAT(' ', r.suffix), '')) AS `Name`, r.position AS `Position`, COALESCE(r.committee, '-') AS `Committee`, COALESCE(r.contact_number, '-') AS `Contact` " &
            "FROM barangay_roster r JOIN barangays b ON b.barangay_id = r.barangay_id WHERE r.status = 'Active'"
        If barangayId > 0 Then
            result.Table = Db.Query(sql & " AND r.barangay_id = @b ORDER BY b.barangay_name, r.last_name", "@b", barangayId)
        Else
            result.Table = Db.Query(sql & " ORDER BY b.barangay_name, r.last_name")
        End If
        Return result
    End Function

    Public Shared Function MonthlyCalendar(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Monthly Calendar Activity Report"
        result.Subtitle = MonthLabel(year, month)
        Dim source As DataTable = CalendarData.ForMonth(year, month, False)
        Dim table As New DataTable()
        table.Columns.Add("Date", GetType(String))
        table.Columns.Add("Event / Activity", GetType(String))
        table.Columns.Add("Type", GetType(String))
        For Each row As DataRow In source.Rows
            table.Rows.Add(Ui.DateText(row("event_day")), CStr(row("title")), CStr(row("kind")))
        Next
        result.Table = table
        Return result
    End Function

    Public Shared Function Announcements(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Announcement Report"
        result.Subtitle = MonthLabel(year, month)
        result.Table = Db.Query("SELECT title AS `Title`, COALESCE(DATE_FORMAT(date_published, '%b %e, %Y'), '-') AS `Published`, COALESCE(priority, '-') AS `Priority`, visibility_type AS `Visibility`, status AS `Status` FROM announcements WHERE status <> 'Draft' AND YEAR(date_published) = @y AND MONTH(date_published) = @m ORDER BY date_published", "@y", year, "@m", month)
        Return result
    End Function

    Public Shared Function LateSubmissions(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Late Barangay Activity Submission Report"
        result.Subtitle = MonthLabel(year, month)
        result.Table = Db.Query("SELECT b.barangay_name AS `Barangay`, COUNT(s.date_id) AS `Late Submissions` FROM barangays b LEFT JOIN submissions s ON s.barangay_id = b.barangay_id AND s.is_late = 1 AND YEAR(s.date_submitted) = @y AND MONTH(s.date_submitted) = @m WHERE b.status = 'Active' GROUP BY b.barangay_id, b.barangay_name ORDER BY `Late Submissions` DESC, b.barangay_name", "@y", year, "@m", month)
        Return result
    End Function

    Public Shared Function NonSubmission(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Barangay Non-Submission Report"
        result.Subtitle = MonthLabel(year, month)
        result.Table = Db.Query("SELECT b.barangay_name AS `Barangay`, COUNT(p.period_id) AS `Activities Not Submitted` FROM barangays b " &
            "LEFT JOIN activity_barangays ab ON ab.barangay_id = b.barangay_id " &
            "LEFT JOIN reporting_period p ON p.activity_id = ab.activity_id AND YEAR(p.submission_deadline) = @y AND MONTH(p.submission_deadline) = @m AND p.submission_deadline < NOW() " &
            "AND NOT EXISTS (SELECT 1 FROM submissions s WHERE s.period_id = p.period_id AND s.barangay_id = b.barangay_id) " &
            "WHERE b.status = 'Active' GROUP BY b.barangay_id, b.barangay_name ORDER BY `Activities Not Submitted` DESC, b.barangay_name", "@y", year, "@m", month)
        Return result
    End Function

    Public Shared Function ReportCard(barangayId As Integer, year As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Individual Barangay Report Card"
        Dim barangayName As Object = Db.Scalar("SELECT barangay_name FROM barangays WHERE barangay_id = @b", "@b", barangayId)
        result.Subtitle = If(barangayName Is Nothing, "Unknown barangay", CStr(barangayName)) & " - " & year
        Dim rank As String = "-"
        Dim total As String = "0"
        For Each row As DataRow In Scoring.Ranking(year, 0).Rows
            If Convert.ToInt32(row("barangay_id")) = barangayId Then
                rank = row("Rank").ToString()
                total = Ui.ScoreText(row("Score"))
            End If
        Next
        result.Notes.Add("Rank: " & rank & " of 15   Total score: " & total)
        result.Table = Db.Query("SELECT a.activity_name AS `Activity`, p.period_name AS `Period`, DATE_FORMAT(p.submission_deadline, '%b %e, %Y') AS `Deadline`, COALESCE(s.submission_status, 'Not Submitted') AS `Status`, IF(s.date_id IS NULL, '-', IF(s.is_late = 1, 'Yes', 'No')) AS `Late`, COALESCE(CAST(s.score AS CHAR), '-') AS `Score` " &
            "FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id JOIN activity_barangays ab ON ab.activity_id = a.activity_id AND ab.barangay_id = @b " &
            "LEFT JOIN submissions s ON s.period_id = p.period_id AND s.barangay_id = @b WHERE YEAR(p.submission_deadline) = @y AND a.activity_status <> 'Archived' ORDER BY p.submission_deadline", "@b", barangayId, "@y", year)
        Return result
    End Function

End Class
