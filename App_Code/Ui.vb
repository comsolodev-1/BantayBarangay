Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Web
Imports System.Web.UI.WebControls

Public Class Ui

    Public Shared Function H(value As Object) As String
        If value Is Nothing OrElse IsDBNull(value) Then Return ""
        Return HttpUtility.HtmlEncode(Convert.ToString(value))
    End Function

    Public Shared Function DateText(value As Object) As String
        If value Is Nothing OrElse IsDBNull(value) Then Return "-"
        Return Convert.ToDateTime(value).ToString("MMM d, yyyy")
    End Function

    Public Shared Function DateTimeText(value As Object) As String
        If value Is Nothing OrElse IsDBNull(value) Then Return "-"
        Return Convert.ToDateTime(value).ToString("MMM d, yyyy h:mm tt")
    End Function

    Public Shared Function ScoreText(value As Object) As String
        If value Is Nothing OrElse IsDBNull(value) Then Return "-"
        Return Convert.ToDecimal(value).ToString("0.0#")
    End Function

    Public Shared Function Badge(status As Object) As String
        Dim text As String = If(status Is Nothing OrElse IsDBNull(status), "", Convert.ToString(status))
        Dim css As String = text.ToLowerInvariant().Replace(" ", "-")
        Return "<span class=""badge badge-" & HttpUtility.HtmlAttributeEncode(css) & """>" & HttpUtility.HtmlEncode(text) & "</span>"
    End Function

    Public Shared Sub Notice(target As Literal, message As String, success As Boolean)
        Dim css As String = If(success, "notice notice-ok", "notice notice-error")
        target.Text = "<div class=""" & css & """>" & HttpUtility.HtmlEncode(message) & "</div>"
    End Sub

    Public Shared Sub Fill(list As ListControl, table As DataTable, textField As String, valueField As String)
        list.DataSource = table
        list.DataTextField = textField
        list.DataValueField = valueField
        list.DataBind()
    End Sub

    Public Shared Sub FillYears(list As DropDownList)
        list.Items.Clear()
        For y As Integer = DateTime.Now.Year + 1 To 2024 Step -1
            list.Items.Add(New ListItem(y.ToString(), y.ToString()))
        Next
        list.SelectedValue = DateTime.Now.Year.ToString()
    End Sub

    Public Shared Sub FillMonths(list As DropDownList)
        list.Items.Clear()
        For m As Integer = 1 To 12
            list.Items.Add(New ListItem(New DateTime(2000, m, 1).ToString("MMMM"), m.ToString()))
        Next
        list.SelectedValue = DateTime.Now.Month.ToString()
    End Sub

End Class
