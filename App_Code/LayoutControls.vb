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
            writer.AddStyleAttribute("box-sizing", "border-box")
            writer.AddStyleAttribute("max-width", "100%")
            writer.AddStyleAttribute("min-width", "0")
            writer.AddStyleAttribute("padding", ContentPadding & "px")
            writer.AddStyleAttribute("overflow-x", "auto")
            If SeparateAfter Then writer.AddStyleAttribute("margin-bottom", "10px")
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    ' Workflow dialog. The save and cancel buttons keep their existing VB.NET handlers.
    Public Class Workflow
        Inherits Panel

        Protected Overrides Sub Render(writer As HtmlTextWriter)
            writer.AddStyleAttribute("position", "fixed")
            writer.AddStyleAttribute("inset", "0")
            writer.AddStyleAttribute("z-index", "20")
            writer.AddStyleAttribute("display", "grid")
            writer.AddStyleAttribute("place-items", "center")
            writer.AddStyleAttribute("padding", "12px")
            writer.AddStyleAttribute("background-color", "#102d24a8")
            writer.RenderBeginTag("div")

            writer.AddAttribute("open", "open")
            writer.AddAttribute("id", ClientID)
            writer.AddAttribute("aria-labelledby", ClientID & "_heading")
            writer.AddStyleAttribute("position", "relative")
            writer.AddStyleAttribute("box-sizing", "border-box")
            writer.AddStyleAttribute("width", "min(640px, 100%)")
            writer.AddStyleAttribute("max-height", "90vh")
            writer.AddStyleAttribute("padding", "0")
            writer.AddStyleAttribute("display", "flex")
            writer.AddStyleAttribute("flex-direction", "column")
            writer.AddStyleAttribute("overflow", "hidden")
            writer.AddStyleAttribute("border", "1px solid #aac6b5")
            writer.AddStyleAttribute("border-radius", "8px")
            writer.AddStyleAttribute("box-shadow", "0 12px 45px #152b2540")
            writer.RenderBeginTag("dialog")
            RenderContents(writer)
            writer.RenderEndTag()
            writer.RenderEndTag()
        End Sub

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            Dim footer As DialogFooter = Nothing
            For Each child As Control In Controls
                If TypeOf child Is DialogTitle Then child.RenderControl(writer)
                If TypeOf child Is DialogFooter Then footer = CType(child, DialogFooter)
            Next

            writer.AddStyleAttribute("min-height", "0")
            writer.AddStyleAttribute("overflow", "auto")
            writer.AddStyleAttribute("padding", "12px 16px")
            writer.RenderBeginTag("div")
            Dim outsideNotice As Literal = TryCast(NamingContainer.FindControl("litMessage"), Literal)
            If outsideNotice IsNot Nothing AndAlso outsideNotice.Parent IsNot Me Then outsideNotice.RenderControl(writer)
            For Each child As Control In Controls
                If Not TypeOf child Is DialogTitle AndAlso child IsNot footer Then child.RenderControl(writer)
            Next
            writer.RenderEndTag()
            If footer IsNot Nothing Then footer.RenderControl(writer)
        End Sub
    End Class

    Public Class DialogTitle
        Inherits Panel

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            writer.AddAttribute("id", Parent.ClientID & "_heading")
            writer.AddAttribute("role", "heading")
            writer.AddAttribute("aria-level", "2")
            writer.AddStyleAttribute("background-color", "#1a3d28")
            writer.AddStyleAttribute("color", "white")
            writer.AddStyleAttribute("font-weight", "600")
            writer.AddStyleAttribute("padding", "12px 16px")
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Public Class DialogFooter
        Inherits Panel

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            writer.AddStyleAttribute("display", "flex")
            writer.AddStyleAttribute("flex-wrap", "wrap")
            writer.AddStyleAttribute("justify-content", "flex-end")
            writer.AddStyleAttribute("gap", "8px")
            writer.AddStyleAttribute("padding", "10px 16px")
            writer.AddStyleAttribute("flex-shrink", "0")
            writer.AddStyleAttribute("border-top", "1px solid #86a793")
            writer.AddStyleAttribute("background-color", "white")
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Public Class DataGrid
        Inherits GridView

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            writer.AddStyleAttribute("border-collapse", "collapse")
            writer.AddStyleAttribute("overflow-wrap", "anywhere")
            writer.AddStyleAttribute("line-height", "1.4")
            If Not MinimumWidth.IsEmpty Then writer.AddStyleAttribute("min-width", MinimumWidth.ToString())
            MyBase.AddAttributesToRender(writer)
        End Sub

        Public Property MinimumWidth As Unit = Unit.Empty

        Protected Overrides Sub OnPreRender(e As EventArgs)
            MyBase.OnPreRender(e)
            If HeaderRow IsNot Nothing Then SetCellBorders(HeaderRow)
            For Each row As GridViewRow In Rows
                SetCellBorders(row)
            Next
        End Sub

        Private Sub SetCellBorders(row As GridViewRow)
            For Each cell As TableCell In row.Cells
                cell.BorderColor = ColorTranslator.FromHtml("#8fa399")
                cell.BorderWidth = Unit.Pixel(1)
                cell.BorderStyle = BorderStyle.Solid
                cell.VerticalAlign = VerticalAlign.Middle
            Next
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
            writer.AddStyleAttribute("flex", If(IsSidebar, "1 0 230px", "100 1 min(600px, 100%)"))
            writer.AddStyleAttribute("min-width", "0")
            writer.AddStyleAttribute("box-sizing", "border-box")
            MyBase.AddAttributesToRender(writer)
        End Sub

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            If Not IsSidebar Then
                MyBase.RenderContents(writer)
                Return
            End If

            ' The outer pane spans its flex row. If it wraps onto a row of its own,
            ' the sticky menu is bounded by that row so it can scroll offscreen.
            writer.AddStyleAttribute("position", "sticky")
            writer.AddStyleAttribute("top", "0")
            writer.AddStyleAttribute("max-height", "100dvh")
            writer.AddStyleAttribute("overflow-y", "auto")
            writer.RenderBeginTag(HtmlTextWriterTag.Div)
            MyBase.RenderContents(writer)
            writer.RenderEndTag()
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
            writer.AddStyleAttribute("display", "flex")
            writer.AddStyleAttribute("flex-wrap", "wrap")
            writer.AddStyleAttribute("align-items", If(ItemVerticalAlign = VerticalAlign.Bottom, "end", "start"))
            writer.AddStyleAttribute("gap", RowGapPixels & "px " & GapPixels & "px")
            writer.AddStyleAttribute("margin-bottom", "12px")
            MyBase.AddAttributesToRender(writer)
        End Sub

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            For Each child As Control In Controls
                If TypeOf child Is Panel AndAlso child.Visible Then
                    writer.AddStyleAttribute("flex", If(Columns = 1, "1 1 100%", "1 1 12rem"))
                    writer.AddStyleAttribute("min-width", "0")
                    writer.RenderBeginTag("div")
                    child.RenderControl(writer)
                    writer.RenderEndTag()
                Else
                    child.RenderControl(writer)
                End If
            Next
        End Sub
    End Class

    Public Class ActionButton
        Inherits Button
        Public Property BlockLayout As Boolean = False

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            ActionAppearance.Write(writer)
            MyBase.AddAttributesToRender(writer)
        End Sub

        Protected Overrides Sub Render(writer As HtmlTextWriter)
            ActionAppearance.RenderConfirmation(writer, Me, Text, Sub(output) MyBase.Render(output))
        End Sub
    End Class

    Public Class ActionLink
        Inherits LinkButton

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            ActionAppearance.Write(writer)
            writer.AddStyleAttribute("display", "inline-block")
            writer.AddStyleAttribute("text-decoration", "none")
            writer.AddStyleAttribute("margin", "2px")
            MyBase.AddAttributesToRender(writer)
        End Sub

        Protected Overrides Sub Render(writer As HtmlTextWriter)
            ActionAppearance.RenderConfirmation(writer, Me, Text, Sub(output) MyBase.Render(output))
        End Sub
    End Class

    Friend Class ActionAppearance
        Public Shared Sub Write(writer As HtmlTextWriter)
            writer.AddStyleAttribute("padding", "6px 10px")
            writer.AddStyleAttribute("border-radius", "5px")
            writer.AddStyleAttribute("font", "inherit")
            writer.AddStyleAttribute("cursor", "pointer")
        End Sub

        ' Action confirmation. A native popover keeps the form and any chosen file in place.
        Public Shared Sub RenderConfirmation(writer As HtmlTextWriter, action As WebControl, caption As String,
                                             renderAction As Action(Of HtmlTextWriter))
            Dim question As String = action.Attributes("data-confirm")
            If String.IsNullOrEmpty(question) Then
                renderAction(writer)
                Return
            End If

            Dim popoverId As String = action.ClientID & "_confirm"
            action.ControlStyle.AddAttributesToRender(writer, action)
            Write(writer)
            writer.AddStyleAttribute("margin", "2px")
            writer.AddAttribute("type", "button")
            writer.AddAttribute("popovertarget", popoverId)
            writer.RenderBeginTag("button")
            writer.WriteEncodedText(caption)
            writer.RenderEndTag()

            writer.AddAttribute("id", popoverId)
            writer.AddAttribute("popover", "auto")
            writer.AddAttribute("role", "dialog")
            writer.AddAttribute("aria-label", "Confirm action")
            writer.AddStyleAttribute("width", "min(350px, 85vw)")
            writer.AddStyleAttribute("padding", "20px")
            writer.AddStyleAttribute("border", "1px solid #86a793")
            writer.AddStyleAttribute("border-radius", "8px")
            writer.AddStyleAttribute("box-shadow", "0 6px 25px #17362655")
            writer.RenderBeginTag("div")
            writer.RenderBeginTag("strong")
            writer.WriteEncodedText(question)
            writer.RenderEndTag()
            Dim description As String = action.Attributes("data-description")
            If Not String.IsNullOrEmpty(description) Then
                writer.RenderBeginTag("p")
                writer.WriteEncodedText(description)
                writer.RenderEndTag()
            End If
            writer.AddStyleAttribute("text-align", "right")
            writer.AddStyleAttribute("margin-top", "12px")
            writer.RenderBeginTag("div")
            Write(writer)
            writer.AddAttribute("type", "button")
            writer.AddAttribute("popovertarget", popoverId)
            writer.AddAttribute("popovertargetaction", "hide")
            writer.AddAttribute("autofocus", "autofocus")
            writer.RenderBeginTag("button")
            writer.Write("Cancel")
            writer.RenderEndTag()
            writer.Write(" ")
            renderAction(writer)
            writer.RenderEndTag()
            writer.RenderEndTag()
        End Sub
    End Class

    Public Class FormTextBox
        Inherits TextBox

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            FieldAppearance.Write(writer)
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Public Class FormSelect
        Inherits DropDownList

        Protected Overrides Sub AddAttributesToRender(writer As HtmlTextWriter)
            FieldAppearance.Write(writer)
            MyBase.AddAttributesToRender(writer)
        End Sub
    End Class

    Friend Class FieldAppearance
        Public Shared Sub Write(writer As HtmlTextWriter)
            writer.AddStyleAttribute("display", "block")
            writer.AddStyleAttribute("box-sizing", "border-box")
            writer.AddStyleAttribute("width", "100%")
            writer.AddStyleAttribute("max-width", "100%")
            writer.AddStyleAttribute("min-height", "36px")
            writer.AddStyleAttribute("padding", "6px 8px")
            writer.AddStyleAttribute("font", "inherit")
            writer.AddStyleAttribute("border-radius", "5px")
        End Sub
    End Class
End Namespace
