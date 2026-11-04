Imports System
Imports System.Collections.Generic
Imports System.Drawing
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace BarangayLayout
    Public Class Card
        Inherits Panel

        Public Property SurfaceColor As Color = Color.White
        Public Property CornerSize As Integer = 10
        Public Property ContentPadding As Integer = 10
        Public Property SeparateAfter As Boolean = True

        Private Class BodyContent
            Inherits Control
            Public Property WriteBody As Action(Of HtmlTextWriter)
            Protected Overrides Sub Render(writer As HtmlTextWriter)
                WriteBody.Invoke(writer)
            End Sub
        End Class

        Private Function Rim(top As Boolean) As TableRow
            Dim row As New TableRow With {.Height = Unit.Pixel(CornerSize)}
            For column As Integer = 0 To 2
                Dim cell As New TableCell With {.Height = Unit.Pixel(CornerSize), .VerticalAlign = VerticalAlign.Top}
                ' Zero text size removes the image baseline gap around the corner.
                cell.Font.Size = FontUnit.Point(0)
                If column = 1 Then
                    cell.BackColor = SurfaceColor
                Else
                    cell.Width = Unit.Pixel(CornerSize)
                    Dim angle As Integer = If(top, If(column = 0, 0, 90), If(column = 0, 270, 180))
                    Dim svg As String = "<svg xmlns='http://www.w3.org/2000/svg' width='10' height='10'><path transform='rotate(" & angle & " 5 5)' d='M0 10Q0 0 10 0V10Z' fill='" & ColorTranslator.ToHtml(SurfaceColor) & "'/></svg>"
                    Dim image As New WebControls.Image With {
                        .ImageUrl = "data:image/svg+xml;base64," & Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(svg)),
                        .AlternateText = "", .GenerateEmptyAlternateText = True,
                        .Width = Unit.Pixel(CornerSize), .Height = Unit.Pixel(CornerSize), .ImageAlign = ImageAlign.Top}
                    cell.Controls.Add(image)
                End If
                row.Cells.Add(cell)
            Next
            Return row
        End Function

        Private Sub WriteBody(writer As HtmlTextWriter)
            MyBase.RenderContents(writer)
        End Sub

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            Dim frame As New Table With {.Width = Unit.Percentage(100), .CellPadding = 0, .CellSpacing = 0, .BorderWidth = Unit.Pixel(0)}
            frame.Attributes("role") = "presentation"
            frame.Rows.Add(Rim(True))
            Dim row As New TableRow()
            Dim cell As New TableCell With {.ColumnSpan = 3, .BackColor = SurfaceColor}
            Dim inner As New Table With {.Width = Unit.Percentage(100), .CellPadding = ContentPadding, .CellSpacing = 0}
            inner.Attributes("role") = "presentation"
            Dim contentRow As New TableRow()
            Dim contentCell As New TableCell()
            contentCell.Controls.Add(New BodyContent With {.WriteBody = AddressOf WriteBody})
            contentRow.Cells.Add(contentCell)
            inner.Rows.Add(contentRow)
            cell.Controls.Add(inner)
            row.Cells.Add(cell)
            frame.Rows.Add(row)
            frame.Rows.Add(Rim(False))
            frame.RenderControl(writer)
            If SeparateAfter Then writer.Write("<br />")
        End Sub
    End Class

    Public Class HeaderLink
        Inherits HyperLink

        Public Property Filled As Boolean
        Public Property SurfaceColor As Color = Color.White

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            If Not Filled Then
                MyBase.RenderContents(writer)
                Return
            End If
            Dim surface As New Card With {.SurfaceColor = SurfaceColor, .CornerSize = 4,
                                          .ContentPadding = 6, .SeparateAfter = False}
            surface.Controls.Add(New LiteralControl(Text))
            surface.RenderControl(writer)
        End Sub
    End Class

    Public Class FieldRow
        Inherits Panel

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            Dim items As New List(Of Control)()
            For Each item As Control In Controls
                Dim literal As LiteralControl = TryCast(item, LiteralControl)
                If item.Visible AndAlso (literal Is Nothing OrElse Not String.IsNullOrWhiteSpace(literal.Text)) Then items.Add(item)
            Next
            If items.Count = 0 Then Return
            Dim columns As Integer = If(Page.Request.Browser.IsMobileDevice, 1, Math.Min(3, items.Count))
            Dim table As New Table With {.Width = Unit.Percentage(100), .CellPadding = 5, .CellSpacing = 0}
            table.Attributes("role") = "presentation"
            For i As Integer = 0 To items.Count - 1
                If i Mod columns = 0 Then table.Rows.Add(New TableRow())
                Dim cell As New TableCell With {.Width = Unit.Percentage(100D / columns), .VerticalAlign = VerticalAlign.Top}
                ' Render existing controls in place so their postback IDs stay stable.
                cell.Controls.Add(New ItemContent With {.Item = items(i)})
                table.Rows(table.Rows.Count - 1).Cells.Add(cell)
            Next
            table.RenderControl(writer)
        End Sub

        Private Class ItemContent
            Inherits Control
            Public Property Item As Control
            Protected Overrides Sub Render(writer As HtmlTextWriter)
                Item.RenderControl(writer)
            End Sub
        End Class
    End Class
End Namespace
