Imports System.Data

Partial Class Barangay_Dashboard
    Inherits BarangayPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Dim data As DataTable = Assignments.SummaryForBarangay(Auth.BarangayCode)
        Dim notSubmitted As Integer = 0
        Dim pending As Integer = 0
        Dim confirmed As Integer = 0
        Dim denied As Integer = 0
        Dim actionableMissing As Integer = 0
        Dim actionableDenied As Integer = 0
        For Each row As DataRow In data.Rows
            Select Case CStr(row("display_status"))
                Case "Not Submitted"
                    notSubmitted = CInt(row("total"))
                    actionableMissing = CInt(row("actionable"))
                Case "Pending"
                    pending = CInt(row("total"))
                Case "Confirmed"
                    confirmed = CInt(row("total"))
                Case "Denied"
                    denied = CInt(row("total"))
                    actionableDenied = CInt(row("actionable"))
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

        gvDeadlines.DataSource = Assignments.UpcomingForBarangay(Auth.BarangayCode)
        gvDeadlines.DataBind()
    End Sub

End Class
