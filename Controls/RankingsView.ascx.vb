Imports System.Data

Partial Class RankingsView
    Inherits System.Web.UI.UserControl

    Public Property HighlightBarangayId As Integer

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
        gvRank.DataSource = Scoring.Ranking(CInt(ddlYear.SelectedValue), CInt(ddlMonth.SelectedValue))
        gvRank.DataBind()
    End Sub

    Protected Sub Filter_Changed(sender As Object, e As EventArgs)
        BindRanking()
    End Sub

    Protected Sub gvRank_RowDataBound(sender As Object, e As GridViewRowEventArgs)
        If e.Row.RowType <> DataControlRowType.DataRow Then Return
        Dim view As DataRowView = CType(e.Row.DataItem, DataRowView)
        If HighlightBarangayId > 0 AndAlso Convert.ToInt32(view("barangay_id")) = HighlightBarangayId Then
            e.Row.Style("background") = "#e6f2ec"
            e.Row.Style("font-weight") = "600"
        End If
        If Convert.ToInt32(view("Rank")) = 1 AndAlso Convert.ToDecimal(view("Score")) > 0 Then
            e.Row.CssClass = "rank-1"
        End If
    End Sub

End Class
