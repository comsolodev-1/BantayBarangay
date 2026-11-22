Imports System.Data
Imports System.Collections.Generic
Imports System.Globalization

Partial Class Super_AuditLogs
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        barangay.Items.Add(New ListItem("All barangays", ""))
        For Each row As DataRow In Db.Query("SELECT barangay_code, barangay_name FROM barangays ORDER BY barangay_name").Rows
            barangay.Items.Add(New ListItem(CStr(row("barangay_name")), CStr(row("barangay_code"))))
        Next
        actionFilter.Items.Add(New ListItem("All actions", ""))
        For Each row As DataRow In Db.Query("SELECT DISTINCT action_name FROM audit_log ORDER BY action_name").Rows
            actionFilter.Items.Add(CStr(row("action_name")))
        Next
        moduleFilter.Items.Add(New ListItem("All modules", ""))
        For Each row As DataRow In Db.Query("SELECT DISTINCT entity_name FROM audit_log ORDER BY entity_name").Rows
            Dim name = CStr(row("entity_name"))
            moduleFilter.Items.Add(New ListItem(ModuleTitle(name), name))
        Next
        BindEvents(0)
    End Sub

    Private Shared Function ModuleTitle(name As String) As String
        Select Case name
            Case "activity_barangays"
                Return "Activity Assignments"
            Case "users"
                Return "User Accounts"
            Case "reporting_period"
                Return "Reporting Periods"
        End Select
        Return CultureInfo.InvariantCulture.TextInfo.ToTitleCase(name.Replace("_", " "))
    End Function

    Protected Sub Search_Click(sender As Object, e As EventArgs)
        BindEvents(0)
    End Sub

    Protected Sub Page_Click(sender As Object, e As EventArgs)
        BindEvents(CInt(ViewState("PageIndex")) + If(sender Is older, 1, -1))
    End Sub

    ' Audit log filters: include the entire end date when searching for changes.
    Private Sub BindEvents(index As Integer)
        Dim clause As String = " FROM audit_log l WHERE 1=1"
        Dim args As New List(Of Object)
        For Each box As TextBox In New TextBox() {dateFrom, dateTo}
            If box.Text = "" Then Continue For
            Dim day As DateTime
            If Not DateTime.TryParseExact(box.Text, "yyyy-MM-dd", CultureInfo.InvariantCulture, DateTimeStyles.None, day) Then
                Ui.Notice(litFilterMessage, "Enter a valid date.", False)
                Return
            End If
            clause &= If(box Is dateFrom, " AND occurred_at >= @start", " AND occurred_at < DATE_ADD(@finish, INTERVAL 1 DAY)")
            args.AddRange(New Object() {If(box Is dateFrom, "@start", "@finish"), day})
        Next
        If dateFrom.Text <> "" AndAlso dateTo.Text <> "" AndAlso String.CompareOrdinal(dateFrom.Text,dateTo.Text) > 0 Then
            Ui.Notice(litFilterMessage, "The end date must be on or after the start date.", False)
            Return
        End If
        If barangay.SelectedValue <> "" Then
            clause &= " AND l.barangay_code = @b"
            args.AddRange(New Object() {"@b", barangay.SelectedValue})
        End If
        If actionFilter.SelectedValue <> "" Then
            clause &= " AND action_name = @action"
            args.AddRange(New Object() {"@action", actionFilter.SelectedValue})
        End If
        If moduleFilter.SelectedValue <> "" Then
            clause &= " AND entity_name = @module"
            args.AddRange(New Object() {"@module", moduleFilter.SelectedValue})
        End If
        If reportId.Text.Trim() <> "" Then
            clause &= " AND entity_name = 'submissions' AND record_id = @report"
            args.AddRange(New Object() {"@report", reportId.Text.Trim()})
        End If
        If searchText.Text.Trim() <> "" Then
            clause &= " AND LOCATE(@text,l.description)>0"
            args.AddRange(New Object() {"@text", searchText.Text.Trim()})
        End If
        Dim total = Db.ScalarInt("SELECT COUNT(*)" & clause, args.ToArray())
        Dim pages = Math.Max(1,CInt(Math.Ceiling(total / 25.0)))
        index = Math.Max(0,Math.Min(index,pages-1))
        Dim joins = " LEFT JOIN barangays b ON b.barangay_code=l.barangay_code LEFT JOIN users u ON u.user_id=l.performed_by_user_id LEFT JOIN roles r ON r.role_id=u.role_id "
        Dim cols = "SELECT l.*, COALESCE(b.barangay_name,l.barangay_code,'All / System') AS Barangay, COALESCE(CONCAT(u.username,' (',r.role_name,')'), CASE WHEN action_name IN ('Submitted','Confirmed','Denied') THEN COALESCE(b.barangay_name,l.barangay_code) END,'System (backfilled)') AS Performer"
        args.AddRange(New Object() {"@offset",index*25})
        Dim rows = Db.Query(cols & clause.Replace(" WHERE", joins & " WHERE") & " ORDER BY occurred_at DESC, log_id DESC LIMIT 25 OFFSET @offset",args.ToArray())
        rows.Columns.Add("ModuleName")
        For Each row As DataRow In rows.Rows
            row("ModuleName") = ModuleTitle(CStr(row("entity_name")))
        Next
        eventsGrid.DataSource = rows
        eventsGrid.DataBind()
        ViewState("PageIndex") = index
        previous.Enabled = index > 0
        older.Enabled = index < pages-1
        message.Text = total & " entries · Page " & (index+1) & " of " & pages
    End Sub
End Class
