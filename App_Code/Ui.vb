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

    Public Shared Sub AddNavLink(menu As PlaceHolder, caption As String, url As String, Optional stacked As Boolean = False)
        Dim link As New HyperLink With {.Text = H(caption), .NavigateUrl = url, .SkinID = "Navigation"}
        If String.Equals(menu.Page.Request.Url.AbsolutePath, menu.ResolveUrl(url), StringComparison.OrdinalIgnoreCase) Then
            link.Font.Bold = True
            link.Attributes("aria-current") = "page"
        End If
        menu.Controls.Add(link)
        menu.Controls.Add(New LiteralControl(If(stacked, "<br />", " &nbsp; ")))
    End Sub

    Private Shared Function ColoredText(value As String, background As String, foreground As String) As String
        Dim label As New Label With {.Text = H(value), .BackColor = Drawing.ColorTranslator.FromHtml(background),
                                     .ForeColor = Drawing.ColorTranslator.FromHtml(foreground)}
        label.Font.Bold = True
        Using buffer As New IO.StringWriter()
            Using writer As New HtmlTextWriter(buffer)
                label.RenderControl(writer)
            End Using
            Return buffer.ToString()
        End Using
    End Function

    Public Shared Function Badge(status As Object) As String
        Dim value As String = Convert.ToString(status)
        Select Case value
            Case "Confirmed", "Active", "Published", "Open", "Good"
                Return ColoredText(value, "#D9EFE1", "#14532D")
            Case "Pending", "Draft", "Upcoming", "Needs Improvement", "Closed", "Medium", "Pinned"
                Return ColoredText(value, "#FEF9E7", "#7D5A00")
            Case "Denied", "Bad", "Overdue", "High", "Suspended", "Late"
                Return ColoredText(value, "#F2DEDE", "#A94442")
            Case Else
                Return ColoredText(value, "#ECECEC", "#444444")
        End Select
    End Function

    Public Shared Sub Notice(target As Literal, message As String, success As Boolean)
        target.Text = "<p role=""status"">" & ColoredText(message, If(success, "#E6F2EC", "#F2DEDE"),
                                                        If(success, "#1A3D28", "#A94442")) & "</p>"
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
