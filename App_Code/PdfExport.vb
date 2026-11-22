Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.IO
Imports System.Web
Imports iTextSharp.text
Imports iTextSharp.text.pdf

Public Class PdfExport

    Public Shared Sub Send(response As HttpResponse, report As ReportResult, fileName As String, Optional minimumRows As Integer = 0)
        Dim bytes() As Byte
        Using stream As New MemoryStream()
            Dim document As New Document(PageSize.A4.Rotate(), 36, 36, 36, 36)
            PdfWriter.GetInstance(document, stream)
            document.Open()

            Dim headFont As Font = FontFactory.GetFont(FontFactory.HELVETICA, 9)
            Dim titleFont As Font = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 15)
            Dim subFont As Font = FontFactory.GetFont(FontFactory.HELVETICA, 10)
            Dim cellFont As Font = FontFactory.GetFont(FontFactory.HELVETICA, 9)
            Dim headerCellFont As Font = FontFactory.GetFont(FontFactory.HELVETICA_BOLD, 9)

            Dim banner As New PdfPTable(New Single() {80, 330, 80})
            banner.TotalWidth = 490
            banner.LockedWidth = True
            banner.HorizontalAlignment = Element.ALIGN_CENTER
            For Each item As String In New String() {"dilg-report.png", "", "talisay-report.png"}
                Dim cell As New PdfPCell()
                cell.Border = Rectangle.NO_BORDER
                cell.HorizontalAlignment = Element.ALIGN_CENTER
                cell.VerticalAlignment = Element.ALIGN_MIDDLE
                If item = "" Then
                    cell.Phrase = New Phrase("Republic of the Philippines" & vbLf & "DILG Municipal Office of Talisay, Camarines Norte", headFont)
                Else
                    Dim logo As iTextSharp.text.Image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Content/" & item))
                    logo.ScaleToFit(76, 76)
                    cell.Phrase = New Phrase(New Chunk(logo, 0, 0, True))
                End If
                banner.AddCell(cell)
            Next
            document.Add(banner)
            Dim titleLine As New Paragraph(report.Title, titleFont)
            titleLine.Alignment = Element.ALIGN_CENTER
            titleLine.SpacingBefore = 8
            document.Add(titleLine)
            Dim subtitleLine As New Paragraph(report.Subtitle, subFont)
            subtitleLine.Alignment = Element.ALIGN_CENTER
            subtitleLine.SpacingAfter = 4
            document.Add(subtitleLine)
            Dim generated As New Paragraph("Generated " & DateTime.Now.ToString("MMM d, yyyy h:mm tt"), headFont)
            generated.Alignment = Element.ALIGN_CENTER
            generated.SpacingAfter = 10
            document.Add(generated)

            For Each note As String In report.Notes
                Dim notePara As New Paragraph(note, subFont)
                notePara.SpacingAfter = 6
                document.Add(notePara)
            Next

            Dim output As DataTable = report.TableWithBlankRows(minimumRows)
            Dim formal As Boolean = minimumRows > 0
            Dim columnCount As Integer = output.Columns.Count
            If columnCount > 0 Then
                Dim grid As New PdfPTable(columnCount)
                grid.WidthPercentage = 100
                For Each column As DataColumn In output.Columns
                    Dim headerCell As New PdfPCell(New Phrase(column.ColumnName, headerCellFont))
                    headerCell.BackgroundColor = If(formal, BaseColor.WHITE, New BaseColor(230, 242, 236))
                    headerCell.BorderColor = BaseColor.BLACK
                    If formal Then headerCell.MinimumHeight = 21
                    headerCell.Padding = 5
                    grid.AddCell(headerCell)
                Next
                grid.HeaderRows = 1
                For Each row As DataRow In output.Rows
                    For Each column As DataColumn In output.Columns
                        Dim text As String = If(IsDBNull(row(column)), "", Convert.ToString(row(column)))
                        Dim bodyCell As New PdfPCell(New Phrase(text, cellFont))
                        bodyCell.Padding = If(formal, 5.0F, 6.0F)
                        bodyCell.BorderColor = BaseColor.BLACK
                        If formal Then bodyCell.MinimumHeight = 21
                        grid.AddCell(bodyCell)
                    Next
                Next
                If output.Rows.Count = 0 Then
                    Dim emptyCell As New PdfPCell(New Phrase("No records for the selected filters.", cellFont))
                    emptyCell.Colspan = columnCount
                    emptyCell.Padding = 8
                    grid.AddCell(emptyCell)
                End If
                document.Add(grid)
            End If

            document.Close()
            bytes = stream.ToArray()
        End Using

        Dim safeName As String = fileName.Replace("""", "").Replace(vbCr, "").Replace(vbLf, "")
        response.Clear()
        response.ContentType = "application/pdf"
        response.AddHeader("Content-Disposition", "attachment; filename=""" & safeName & """")
        response.BinaryWrite(bytes)
        response.Flush()
        HttpContext.Current.ApplicationInstance.CompleteRequest()
    End Sub

End Class
