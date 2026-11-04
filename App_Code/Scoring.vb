Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class Scoring

    Public Const OnTimeScore As Decimal = 1D
    Public Const LateScore As Decimal = 0.5D

    Public Shared Function ScoreFor(isLate As Boolean) As Decimal
        If isLate Then Return LateScore
        Return OnTimeScore
    End Function

    Public Shared Function Ranking(year As Integer, month As Integer) As DataTable
        Dim sql As String = "SELECT b.barangay_id, b.barangay_name, " &
            "COALESCE(SUM(CASE WHEN s.submission_status = 'Confirmed' THEN 1 ELSE 0 END), 0) AS confirmed_count, " &
            "COALESCE(SUM(CASE WHEN s.submission_status = 'Confirmed' AND s.is_late = 1 THEN 1 ELSE 0 END), 0) AS late_count, " &
            "COALESCE(SUM(CASE WHEN s.submission_status = 'Confirmed' THEN s.score ELSE 0 END), 0) AS total_score " &
            "FROM barangays b LEFT JOIN (SELECT x.barangay_id, x.submission_status, x.is_late, x.score FROM submissions x " &
            "JOIN reporting_period p ON p.period_id = x.period_id WHERE YEAR(p.submission_deadline) = @year"
        If month > 0 Then sql &= " AND MONTH(p.submission_deadline) = @month"
        sql &= ") s ON s.barangay_id = b.barangay_id WHERE b.status = 'Active' GROUP BY b.barangay_id, b.barangay_name " &
            "ORDER BY total_score DESC, confirmed_count DESC, b.barangay_name"

        Dim source As DataTable
        If month > 0 Then
            source = Db.Query(sql, "@year", year, "@month", month)
        Else
            source = Db.Query(sql, "@year", year)
        End If

        Dim result As New DataTable()
        result.Columns.Add("Rank", GetType(Integer))
        result.Columns.Add("Barangay", GetType(String))
        result.Columns.Add("Confirmed", GetType(Integer))
        result.Columns.Add("Late", GetType(Integer))
        result.Columns.Add("Score", GetType(Decimal))
        result.Columns.Add("barangay_id", GetType(Integer))

        Dim position As Integer = 0
        Dim currentRank As Integer = 0
        Dim previousScore As Decimal = -1D
        For Each row As DataRow In source.Rows
            position += 1
            Dim score As Decimal = Convert.ToDecimal(row("total_score"))
            If score <> previousScore Then currentRank = position
            previousScore = score
            result.Rows.Add(currentRank, CStr(row("barangay_name")), Convert.ToInt32(row("confirmed_count")), Convert.ToInt32(row("late_count")), score, Convert.ToInt32(row("barangay_id")))
        Next
        Return result
    End Function

End Class
