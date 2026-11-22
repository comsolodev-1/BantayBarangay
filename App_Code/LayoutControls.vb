Imports System
Imports System.Collections.Generic
Imports System.Drawing
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace BarangayLayout
    Friend Class FrameRenderer
        Private Class Content
            Inherits Control
            Public Property WriteContent As Action(Of HtmlTextWriter)
            Protected Overrides Sub Render(writer As HtmlTextWriter)
                WriteContent.Invoke(writer)
            End Sub
        End Class

        Private Shared Function Cell(color As Color, width As Integer, height As Integer) As TableCell
            Dim result As New TableCell With {.BackColor = color, .VerticalAlign = VerticalAlign.Top}
            If width > 0 Then result.Width = Unit.Pixel(width)
            If height > 0 Then result.Height = Unit.Pixel(height)
            result.Font.Size = FontUnit.Point(0)
            Return result
        End Function

        Private Shared Function Edge(top As Boolean, size As Integer, fill As Color, border As Color) As TableRow
            Dim row As New TableRow()
            For column As Integer = 0 To 2
                Dim c As TableCell = Cell(Color.Empty, If(column = 1, 0, size), size)
                If column = 1 Then
                    Dim strip As New Table With {.Width = Unit.Percentage(100), .CellPadding = 0, .CellSpacing = 0}
                    Dim first As New TableRow()
                    first.Cells.Add(Cell(If(top, border, fill), 0, If(top, 1, size - 1)))
                    Dim second As New TableRow()
                    second.Cells.Add(Cell(If(top, fill, border), 0, If(top, size - 1, 1)))
                    strip.Rows.Add(first)
                    strip.Rows.Add(second)
                    c.Controls.Add(strip)
                Else
                    Dim angle As Integer = If(top, If(column = 0, 0, 90), If(column = 0, 270, 180))
                    Dim svg As String = "<svg xmlns='http://www.w3.org/2000/svg' viewBox='0 0 10 10'><g transform='rotate(" & angle & " 5 5)'><path d='M0 10Q0 0 10 0V10Z' fill='" & ColorTranslator.ToHtml(fill) & "'/><path d='M.5 10Q.5 .5 10 .5' fill='none' stroke='" & ColorTranslator.ToHtml(border) & "' stroke-width='1'/></g></svg>"
                    c.Controls.Add(New WebControls.Image With {
                        .ImageUrl = "data:image/svg+xml;base64," & Convert.ToBase64String(System.Text.Encoding.UTF8.GetBytes(svg)),
                        .GenerateEmptyAlternateText = True, .AlternateText = "",
                        .Width = Unit.Pixel(size), .Height = Unit.Pixel(size), .ImageAlign = ImageAlign.Top})
                End If
                row.Cells.Add(c)
            Next
            Return row
        End Function

        Public Shared Sub Render(writer As HtmlTextWriter, body As Action(Of HtmlTextWriter), fill As Color,
                                 border As Color, radius As Integer, padding As Integer, gap As Boolean)
            Dim frame As New Table With {.Width = Unit.Percentage(100), .CellPadding = 0, .CellSpacing = 0}
            frame.Attributes("role") = "presentation"
            frame.Rows.Add(Edge(True, radius, fill, border))
            Dim middle As New TableRow()
            Dim box As New TableCell With {.ColumnSpan = 3, .BackColor = fill}
            Dim sides As New Table With {.Width = Unit.Percentage(100), .CellPadding = 0, .CellSpacing = 0}
            Dim sideRow As New TableRow()
            sideRow.Cells.Add(Cell(border, 1, 0))
            Dim padded As New Table With {.Width = Unit.Percentage(100), .CellPadding = padding, .CellSpacing = 0}
            Dim contentRow As New TableRow()
            Dim contentCell As New TableCell()
            contentCell.Controls.Add(New Content With {.WriteContent = body})
            contentRow.Cells.Add(contentCell)
            padded.Rows.Add(contentRow)
            Dim center As New TableCell With {.BackColor = fill}
            center.Controls.Add(padded)
            sideRow.Cells.Add(center)
            sideRow.Cells.Add(Cell(border, 1, 0))
            sides.Rows.Add(sideRow)
            box.Controls.Add(sides)
            middle.Cells.Add(box)
            frame.Rows.Add(middle)
            frame.Rows.Add(Edge(False, radius, fill, border))
            frame.RenderControl(writer)
            If gap Then
                Dim spacer As New Table With {.Width = Unit.Percentage(100), .CellPadding = 0, .CellSpacing = 0}
                Dim row As New TableRow()
                row.Cells.Add(Cell(Color.Empty, 0, 16))
                spacer.Rows.Add(row)
                spacer.RenderControl(writer)
            End If
        End Sub
    End Class

    Public Class Card
        Inherits Panel
        Public Property SurfaceColor As Color = Color.White
        Public Property OutlineColor As Color = ColorTranslator.FromHtml("#A8D5B5")
        Public Property CornerSize As Integer = 7
        Public Property ContentPadding As Integer = 12
        Public Property SeparateAfter As Boolean = True
        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            writer.AddStyleAttribute("background-color", ColorTranslator.ToHtml(SurfaceColor))
            writer.AddStyleAttribute("border", "1px solid " & ColorTranslator.ToHtml(OutlineColor))
            writer.AddStyleAttribute("border-radius", CornerSize & "px")
            writer.AddStyleAttribute("padding", ContentPadding & "px")
            writer.AddStyleAttribute("overflow-x", "auto")
            If SeparateAfter Then writer.AddStyleAttribute("margin-bottom", "10px")
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Public Class HeaderLink
        Inherits HyperLink
        Public Property Filled As Boolean
        Public Property SurfaceColor As Color = Color.White
        Private Sub Body(writer As HtmlTextWriter)
            MyBase.RenderContents(writer)
        End Sub
        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            If Filled Then
                FrameRenderer.Render(writer, AddressOf Body, SurfaceColor, SurfaceColor, 4, 6, False)
            Else
                MyBase.RenderContents(writer)
            End If
        End Sub
    End Class

    Public Class PinnedHeader
        Inherits Panel

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            writer.AddStyleAttribute(HtmlTextWriterStyle.Position, "sticky")
            writer.AddStyleAttribute(HtmlTextWriterStyle.Top, "0")
            writer.AddStyleAttribute(HtmlTextWriterStyle.ZIndex, "10")
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Public Class StaffPane
        Inherits Panel

        Public Property IsSidebar As Boolean

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            If Not Page.Request.Browser.IsMobileDevice Then
                writer.AddStyleAttribute(HtmlTextWriterStyle.Position, "fixed")
                writer.AddStyleAttribute(HtmlTextWriterStyle.Top, "0")
                writer.AddStyleAttribute(HtmlTextWriterStyle.Height, "100%")
                writer.AddStyleAttribute(HtmlTextWriterStyle.Left, If(IsSidebar, "0", "230px"))
                If Not IsSidebar Then writer.AddStyleAttribute("right", "0")
            End If
            Dim originalScrollBars As ScrollBars = ScrollBars
            If Page.Request.Browser.IsMobileDevice Then ScrollBars = System.Web.UI.WebControls.ScrollBars.None
            MyBase.AddAttributesToRender(writer)
            ScrollBars = originalScrollBars
        End Sub
    End Class

    Public Class FieldRow
        Inherits Panel
        Public Property Columns As Integer = 3
        Public Property GapPixels As Integer = 12
        Public Property RowGapPixels As Integer = 12
        Public Property ItemVerticalAlign As VerticalAlign = VerticalAlign.Top
        Public Shared Function Spacer(pixels As Integer) As TableCell
            Dim gap As New TableCell With {.Width = Unit.Pixel(pixels)}
            gap.Font.Size = FontUnit.Point(0)
            gap.Controls.Add(New WebControls.Image With {
                .ImageUrl = "data:image/svg+xml;base64,PHN2ZyB4bWxucz0naHR0cDovL3d3dy53My5vcmcvMjAwMC9zdmcnLz4=",
                .Width = Unit.Pixel(pixels), .Height = Unit.Pixel(1),
                .GenerateEmptyAlternateText = True, .AlternateText = ""})
            Return gap
        End Function

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            CssClass = (CssClass & " field-row").Trim()
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Public Class ActionButton
        Inherits Button
        ' Field-aligned actions must not leave an inline text baseline below their frame.
        Public Property BlockLayout As Boolean = False
    End Class

    Public Class FormTextBox
        Inherits TextBox
    End Class

    Public Class FormSelect
        Inherits DropDownList
    End Class
End Namespace
