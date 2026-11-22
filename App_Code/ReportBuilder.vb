Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class ReportResult
    Public Title As String
    Public Subtitle As String
    Public Summary As String
    Public UsesScores As Boolean
    Public Table As DataTable
    Public Notes As New List(Of String)

    Public Function TableWithBlankRows(minimumRows As Integer) As DataTable
        If Table.Columns.Count = 0 OrElse Table.Rows.Count >= minimumRows Then Return Table

        Dim result As New DataTable()
        For Each column As DataColumn In Table.Columns
            result.Columns.Add(column.ColumnName, GetType(String))
        Next
        For Each sourceRow As DataRow In Table.Rows
            Dim targetRow As DataRow = result.NewRow()
            For i As Integer = 0 To Table.Columns.Count - 1
                targetRow(i) = Convert.ToString(sourceRow(i))
            Next
            result.Rows.Add(targetRow)
        Next
        While result.Rows.Count < minimumRows
            result.Rows.Add(result.NewRow())
        End While
        Return result
    End Function
End Class

Public Class ReportBuilder
    Public Const MinimumPrintRows As Integer = 15

    Public Shared Function ScoringGuide(usesScores As Boolean) As String()
        If Not usesScores Then Return {"This report does not assign compliance scores."}
        Return {"1.0 point: Confirmed report submitted on time.",
                "0.5 points: Confirmed report submitted after the deadline.",
                "0 points: No submission. Pending and denied submissions receive no points unless confirmed."}
    End Function

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
        Dim info As DataRow = Db.QueryRow("SELECT a.activity_id, a.activity_name, p.period_name, p.start_date, p.end_date, p.submission_deadline FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id WHERE p.period_id = @p AND a.activity_status <> 'Archived'", "@p", periodId)
        Dim result As New ReportResult()
        result.Title = frequencyTitle & " Activity Report Submission Summary"
        result.Summary = "This report summarizes submission and review status for the barangays assigned to this activity."
        result.UsesScores = True
        If info Is Nothing Then
            result.Subtitle = "No activity selected."
            result.Table = New DataTable()
            Return result
        End If
        result.Subtitle = CStr(info("activity_name")) & vbLf & "Reporting period: " &
            Ui.DateText(info("start_date")) & " to " & Ui.DateText(info("end_date")) &
            vbLf & "Submission deadline: " & Ui.DateTimeText(info("submission_deadline"))
        result.Table = Db.Query("SELECT ROW_NUMBER() OVER (ORDER BY b.barangay_name) AS `No.`, b.barangay_name AS `Barangay`, " &
            "COALESCE(DATE_FORMAT(s.date_submitted, '%b %e, %Y'), '-') AS `Submission Date`, COALESCE(s.submission_status, 'Not Submitted') AS `Status`, " &
            "IF(s.date_id IS NULL, '-', IF(s.is_late = 1, 'Yes', 'No')) AS `Late`, COALESCE(CAST(s.score AS CHAR), IF(s.date_id IS NULL, '0', '-')) AS `Score`, COALESCE(s.remarks, s.denial_reason, '-') AS `Remarks` " &
            "FROM barangays b JOIN activity_barangays ab ON ab.barangay_code = b.barangay_code AND ab.activity_id = @a " &
            "LEFT JOIN submissions s ON s.barangay_code = b.barangay_code AND s.period_id = @p WHERE b.status = 'Active' ORDER BY b.barangay_name", "@a", CInt(info("activity_id")), "@p", periodId)
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
        result.Summary = "This report ranks barangays by the total compliance points from confirmed submissions in the selected period."
        result.UsesScores = True
        result.Subtitle = If(month > 0, MonthLabel(year, month), "Year " & year)
        Dim source As DataTable = Scoring.Ranking(year, month)
        source.Columns.Remove("barangay_code")
        result.Table = source
        Return result
    End Function

    Public Shared Function Roster(barangayCode As String) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Barangay Roster Report"
        result.Summary = "This report lists active officials, their positions, committees and recorded terms of service."
        result.Subtitle = If(Not String.IsNullOrEmpty(barangayCode), "Selected barangay", "All barangays")
        Dim sql As String = "SELECT b.barangay_name AS `Barangay`, CONCAT_WS(' ', r.first_name, NULLIF(r.middle_name, ''), r.last_name, NULLIF(r.suffix, '')) AS `Name`, r.position AS `Position`, COALESCE(r.committee, '-') AS `Committee`, COALESCE(CONCAT(r.term_start_year, '-', r.term_end_year), '-') AS `Term of Service`, COALESCE(r.contact_number, '-') AS `Contact` " &
            "FROM barangay_roster r JOIN barangays b ON b.barangay_code = r.barangay_code WHERE r.status = 'Active'"
        If Not String.IsNullOrEmpty(barangayCode) Then
            result.Table = Db.Query(sql & " AND r.barangay_code = @b ORDER BY b.barangay_name, r.last_name", "@b", barangayCode)
        Else
            result.Table = Db.Query(sql & " ORDER BY b.barangay_name, r.last_name")
        End If
        Return result
    End Function

    Public Shared Function MonthlyCalendar(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Monthly Calendar Activity Report"
        result.Summary = "This report lists important dates and submission deadlines for the selected month."
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
        result.Summary = "This report lists announcements published during the selected month, with their audience, priority and status."
        result.Subtitle = MonthLabel(year, month)
        result.Table = Db.Query("SELECT title AS `Title`, COALESCE(DATE_FORMAT(date_published, '%b %e, %Y'), '-') AS `Published`, COALESCE(priority, '-') AS `Priority`, visibility_type AS `Visibility`, status AS `Status` FROM announcements WHERE status <> 'Draft' AND YEAR(date_published) = @y AND MONTH(date_published) = @m ORDER BY date_published", "@y", year, "@m", month)
        Return result
    End Function

    Public Shared Function LateSubmissions(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Late Barangay Activity Submission Report"
        result.Summary = "This report counts submissions filed after the deadline during the selected month, grouped by barangay."
        result.UsesScores = True
        result.Subtitle = MonthLabel(year, month)
        result.Table = Db.Query("SELECT b.barangay_name AS `Barangay`, COUNT(s.date_id) AS `Late Submissions` FROM barangays b LEFT JOIN (submissions s JOIN reporting_period p ON p.period_id = s.period_id JOIN activities a ON a.activity_id = p.activity_id AND a.activity_status <> 'Archived') ON s.barangay_code = b.barangay_code AND s.is_late = 1 AND YEAR(s.date_submitted) = @y AND MONTH(s.date_submitted) = @m WHERE b.status = 'Active' GROUP BY b.barangay_code, b.barangay_name ORDER BY `Late Submissions` DESC, b.barangay_name", "@y", year, "@m", month)
        Return result
    End Function

    Public Shared Function NonSubmission(year As Integer, month As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Barangay Non-Submission Report"
        result.Summary = "This report counts assigned reporting periods with a deadline in the selected month that has passed without a submission."
        result.UsesScores = True
        result.Subtitle = MonthLabel(year, month)
        result.Table = Db.Query("SELECT b.barangay_name AS `Barangay`, COUNT(p.period_id) AS `Activities Not Submitted` FROM barangays b " &
            "LEFT JOIN activity_barangays ab ON ab.barangay_code = b.barangay_code " &
            "LEFT JOIN activities a ON a.activity_id = ab.activity_id AND a.activity_status <> 'Archived' " &
            "LEFT JOIN reporting_period p ON p.activity_id = a.activity_id AND YEAR(p.submission_deadline) = @y AND MONTH(p.submission_deadline) = @m AND p.submission_deadline < NOW() " &
            "AND NOT EXISTS (SELECT 1 FROM submissions s WHERE s.period_id = p.period_id AND s.barangay_code = b.barangay_code) " &
            "WHERE b.status = 'Active' GROUP BY b.barangay_code, b.barangay_name ORDER BY `Activities Not Submitted` DESC, b.barangay_name", "@y", year, "@m", month)
        Return result
    End Function

    Public Shared Function ReportCard(barangayCode As String, year As Integer) As ReportResult
        Dim result As New ReportResult()
        result.Title = "Individual Barangay Report Card"
        result.Summary = "This report summarizes assigned reporting periods, submission status and compliance scores for the selected year."
        result.UsesScores = True
        Dim barangayName As Object = Db.Scalar("SELECT barangay_name FROM barangays WHERE barangay_code = @b", "@b", barangayCode)
        result.Subtitle = If(barangayName Is Nothing, "Unknown barangay", CStr(barangayName)) & " - " & year
        Dim rank As String = "-"
        Dim total As String = "0"
        For Each row As DataRow In Scoring.Ranking(year, 0).Rows
            If CStr(row("barangay_code")) = barangayCode Then
                rank = row("Rank").ToString()
                total = Ui.ScoreText(row("Score"))
            End If
        Next
        result.Notes.Add("Rank: " & rank & " of 15   Total score: " & total)
        result.Table = Db.Query("SELECT a.activity_name AS `Activity`, p.period_name AS `Period`, DATE_FORMAT(p.submission_deadline, '%b %e, %Y') AS `Deadline`, COALESCE(s.submission_status, 'Not Submitted') AS `Status`, IF(s.date_id IS NULL, '-', IF(s.is_late = 1, 'Yes', 'No')) AS `Late`, COALESCE(CAST(s.score AS CHAR), '-') AS `Score` " &
            "FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id JOIN activity_barangays ab ON ab.activity_id = a.activity_id AND ab.barangay_code = @b " &
            "LEFT JOIN submissions s ON s.period_id = p.period_id AND s.barangay_code = @b WHERE YEAR(p.submission_deadline) = @y AND a.activity_status <> 'Archived' ORDER BY p.submission_deadline", "@b", barangayCode, "@y", year)
        Return result
    End Function

End Class
