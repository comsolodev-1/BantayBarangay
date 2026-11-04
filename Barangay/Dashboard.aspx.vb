Imports System.Data

Partial Class Barangay_Dashboard
    Inherits BarangayPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Dim data As DataTable = Assignments.ForBarangay(Auth.BarangayId)
        Dim notSubmitted As Integer = 0
        Dim pending As Integer = 0
        Dim confirmed As Integer = 0
        Dim denied As Integer = 0
        Dim todo As DataTable = data.Clone()
        For Each row As DataRow In data.Rows
            Select Case CStr(row("display_status"))
                Case "Not Submitted"
                    notSubmitted += 1
                    todo.ImportRow(row)
                Case "Pending"
                    pending += 1
                Case "Confirmed"
                    confirmed += 1
                Case "Denied"
                    denied += 1
                    todo.ImportRow(row)
            End Select
        Next

        Dim alerts As String = ""
        If notSubmitted > 0 Then alerts &= "<div class=""notice notice-warn""><b>Action required:</b> " & notSubmitted & " activities still need a report submission.</div>"
        If denied > 0 Then alerts &= "<div class=""notice notice-error""><b>Resubmission required:</b> " & denied & " submissions were denied. Review the remarks and resubmit.</div>"
        litAlerts.Text = alerts

        Dim ranking As DataTable = Scoring.Ranking(DateTime.Now.Year, 0)
        Dim rankText As String = "-"
        Dim scoreText As String = "0"
        For Each row As DataRow In ranking.Rows
            If Convert.ToInt32(row("barangay_id")) = Auth.BarangayId Then
                rankText = "#" & row("Rank").ToString()
                scoreText = Ui.ScoreText(row("Score"))
            End If
        Next

        litStats.Text = "<div class=""cards"">" &
            "<div class=""stat""><div class=""num"">" & notSubmitted & "</div><div class=""lbl"">Not submitted</div></div>" &
            "<div class=""stat""><div class=""num"">" & pending & "</div><div class=""lbl"">Pending review</div></div>" &
            "<div class=""stat""><div class=""num"">" & confirmed & "</div><div class=""lbl"">Confirmed</div></div>" &
            "<div class=""stat""><div class=""num"">" & denied & "</div><div class=""lbl"">Denied</div></div>" &
            "<div class=""stat""><div class=""num"">" & scoreText & "</div><div class=""lbl"">Score " & DateTime.Now.Year & "</div></div>" &
            "<div class=""stat""><div class=""num"">" & rankText & "</div><div class=""lbl"">Rank " & DateTime.Now.Year & "</div></div></div>"

        Dim view As DataView = todo.DefaultView
        view.Sort = "submission_deadline ASC"
        Dim limited As DataTable = todo.Clone()
        For i As Integer = 0 To Math.Min(7, view.Count - 1)
            limited.ImportRow(view(i).Row)
        Next
        gvDeadlines.DataSource = limited
        gvDeadlines.DataBind()
    End Sub

End Class
