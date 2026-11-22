Imports System.Data

Partial Class Barangay_Dashboard
    Inherits BarangayPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Dim data As DataTable = Assignments.ForBarangay(Auth.BarangayCode)
        Dim notSubmitted As Integer = 0
        Dim pending As Integer = 0
        Dim confirmed As Integer = 0
        Dim denied As Integer = 0
        Dim actionableMissing As Integer = 0
        Dim actionableDenied As Integer = 0
        Dim todo As DataTable = data.Clone()
        For Each row As DataRow In data.Rows
            Select Case CStr(row("display_status"))
                Case "Not Submitted"
                    notSubmitted += 1
                    If Convert.ToBoolean(row("accepting")) Then
                        actionableMissing += 1
                        todo.ImportRow(row)
                    End If
                Case "Pending"
                    pending += 1
                Case "Confirmed"
                    confirmed += 1
                Case "Denied"
                    denied += 1
                    If Convert.ToBoolean(row("accepting")) Then
                        actionableDenied += 1
                        todo.ImportRow(row)
                    End If
            End Select
        Next

        Dim alerts As String = ""
        If actionableMissing > 0 Then alerts &= "<p><b>Action required:</b> " & actionableMissing & " open reporting periods still need a submission.</p>"
        If actionableDenied > 0 Then alerts &= "<p><b>Resubmission required:</b> " & actionableDenied & " denied submissions can still be resubmitted.</p>"
        litAlerts.Text = alerts

        Dim ranking As DataTable = Scoring.Ranking(DateTime.Now.Year, 0)
        Dim rankText As String = "-"
        Dim scoreText As String = "0"
        For Each row As DataRow In ranking.Rows
            If CStr(row("barangay_code")) = Auth.BarangayCode Then
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
        view.Sort = "cutoff ASC"
        Dim limited As DataTable = todo.Clone()
        For i As Integer = 0 To Math.Min(7, view.Count - 1)
            limited.ImportRow(view(i).Row)
        Next
        gvDeadlines.DataSource = limited
        gvDeadlines.DataBind()
    End Sub

End Class
