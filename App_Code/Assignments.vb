Imports System
Imports System.Collections.Generic
Imports System.Data

Public Class Assignments

    Private Const DisplayStatus As String = "CASE WHEN s.date_id IS NULL THEN 'Not Submitted' ELSE s.submission_status END"
    Private Const Columns As String = "p.period_id, a.activity_id, a.activity_name, a.description, a.frequency, a.instructions, a.template_file_name, " &
            "p.period_name, p.submission_deadline, " & PeriodHelper.CutoffSql & " AS cutoff, " & PeriodHelper.StatusSql & " AS period_status, " &
            "(" & PeriodHelper.AcceptsSubmissionSql & ") AS accepting, s.date_id AS submission_id, s.submission_status, s.date_submitted, s.file_name, " &
            "s.score, s.is_late, s.remarks, s.denial_reason, s.denial_attachment, s.resubmission_count, " &
            DisplayStatus & " AS display_status"
    Private Const Source As String =
            "FROM reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
            "JOIN activity_barangays ab ON ab.activity_id = a.activity_id AND ab.barangay_code = @b " &
            "LEFT JOIN submissions s ON s.period_id = p.period_id AND s.barangay_code = @b " &
            "WHERE a.activity_status <> 'Archived' AND p.submission_deadline IS NOT NULL"
    Private Const OrderBy As String = "p.submission_deadline DESC, a.activity_name, p.period_id DESC"

    Public Shared Function SummaryForBarangay(barangayCode As String) As DataTable
        Return Db.Query("SELECT " & DisplayStatus & " AS display_status, COUNT(*) AS total, " &
                        "SUM(CASE WHEN " & PeriodHelper.AcceptsSubmissionSql & " THEN 1 ELSE 0 END) AS actionable " &
                        Source & " GROUP BY display_status", "@b", barangayCode)
    End Function

    Public Shared Function UpcomingForBarangay(barangayCode As String) As DataTable
        Return Db.Query("SELECT " & Columns & " " & Source & " AND " & PeriodHelper.AcceptsSubmissionSql &
                        " AND (s.date_id IS NULL OR s.submission_status = 'Denied')" &
                        " ORDER BY cutoff, p.period_id LIMIT 8", "@b", barangayCode)
    End Function

    Public Shared Function PageForBarangay(pager As BarangayLayout.RecordPager, barangayCode As String, search As String, status As String) As DataTable
        Return pager.ReadPage(Columns, Source & " AND (@search = '' OR LOCATE(LOWER(@search), LOWER(a.activity_name)) > 0)" &
                              " AND (@status = '' OR (" & DisplayStatus & ") = @status)",
                              OrderBy, "@b", barangayCode, "@search", search, "@status", status)
    End Function

    Public Shared Function CanSubmit(accepting As Object, status As Object) As Boolean
        Return Convert.ToBoolean(accepting) AndAlso (CStr(status) = "Not Submitted" OrElse CStr(status) = "Denied")
    End Function

    Public Shared Function PeriodForBarangay(periodId As Integer, barangayCode As String) As DataRow
        Return Db.QueryRow("SELECT " & Columns & " " & Source & " AND p.period_id = @period",
                           "@b", barangayCode, "@period", periodId)
    End Function

End Class
