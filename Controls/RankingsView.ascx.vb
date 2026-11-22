Imports System.Data

Partial Class RankingsView
    Inherits System.Web.UI.UserControl

    Public Property HighlightBarangayCode As String
    Public Property ShowDenied As Boolean

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.FillYears(ddlYear)
        ddlMonth.Items.Add(New ListItem("All months", "0"))
        For m As Integer = 1 To 12
            ddlMonth.Items.Add(New ListItem(New DateTime(2000, m, 1).ToString("MMMM"), m.ToString()))
        Next
        BindRanking()
    End Sub

    Private Sub BindRanking()
        For Each field As DataControlField In gvRank.Columns
            Dim column As BoundField = TryCast(field, BoundField)
            If column IsNot Nothing AndAlso column.DataField = "Denied" Then column.Visible = ShowDenied
        Next
        gvRank.DataSource = Scoring.Ranking(CInt(ddlYear.SelectedValue), CInt(ddlMonth.SelectedValue))
        gvRank.DataBind()
    End Sub

    Protected Sub Filter_Changed(sender As Object, e As EventArgs)
        BindRanking()
    End Sub

    Protected Sub gvRank_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType <> DataControlRowType.DataRow Then Return
        Dim view As DataRowView = CType(e.Row.DataItem, DataRowView)
        If Not String.IsNullOrEmpty(HighlightBarangayCode) AndAlso CStr(view("barangay_code")) = HighlightBarangayCode Then
            e.Row.BackColor = Drawing.ColorTranslator.FromHtml("#E6F2EC")
            e.Row.Font.Bold = True
        ElseIf Convert.ToInt32(view("Rank")) = 1 AndAlso Convert.ToDecimal(view("Score")) > 0 Then
            e.Row.BackColor = Drawing.ColorTranslator.FromHtml("#FFF7D6")
        End If
    End Sub

End Class
