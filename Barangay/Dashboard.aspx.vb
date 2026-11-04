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
        If notSubmitted > 0 Then alerts &= "<p><b>Action required:</b> " & notSubmitted & " activities still need a report submission.</p>"
        If denied > 0 Then alerts &= "<p><b>Resubmission required:</b> " & denied & " submissions were denied. Review the remarks and resubmit.</p>"
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

        statNotSubmitted.Text = Ui.H(notSubmitted)
        statPending.Text = Ui.H(pending)
        statConfirmed.Text = Ui.H(confirmed)
        statDenied.Text = Ui.H(denied)
        statScoreText.Text = Ui.H(scoreText)
        statScoreTextYear.Text = DateTime.Now.Year.ToString()
        statRankText.Text = Ui.H(rankText)
        statRankTextYear.Text = DateTime.Now.Year.ToString()

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
