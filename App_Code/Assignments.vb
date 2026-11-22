Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class Assignments

    Public Shared Function ForBarangay(barangayCode As String) As DataTable
        Dim sql As String = "SELECT p.period_id, a.activity_id, a.activity_name, a.description, a.frequency, a.instructions, a.template_file_name, " &
            "p.period_name, p.submission_deadline, " & PeriodHelper.CutoffSql & " AS cutoff, " & PeriodHelper.StatusSql & " AS period_status, " &
            "(" & PeriodHelper.AcceptsSubmissionSql & ") AS accepting, s.date_id AS submission_id, s.submission_status, s.date_submitted, s.file_name, " &
            "s.score, s.is_late, s.remarks, s.denial_reason, s.denial_attachment, s.resubmission_count, " &
            "CASE WHEN s.date_id IS NULL THEN 'Not Submitted' ELSE s.submission_status END AS display_status " &
            "FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
            "JOIN activity_barangays ab ON ab.activity_id = a.activity_id AND ab.barangay_code = @b " &
            "LEFT JOIN submissions s ON s.period_id = p.period_id AND s.barangay_code = @b " &
            "WHERE a.activity_status <> 'Archived' AND p.submission_deadline IS NOT NULL ORDER BY p.submission_deadline DESC, a.activity_name"
        Return Db.Query(sql, "@b", barangayCode)
    End Function

    Public Shared Function CanSubmit(accepting As Object, status As Object) As Boolean
        Return Convert.ToBoolean(accepting) AndAlso (CStr(status) = "Not Submitted" OrElse CStr(status) = "Denied")
    End Function

    Public Shared Function PeriodForBarangay(periodId As Integer, barangayCode As String) As DataRow
        Dim table As DataTable = ForBarangay(barangayCode)
        For Each row As DataRow In table.Rows
            If Convert.ToInt32(row("period_id")) = periodId Then Return row
        Next
        Return Nothing
    End Function

End Class
