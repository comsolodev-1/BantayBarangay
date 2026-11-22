Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.IO
Imports System.Web
Imports iTextSharp.text
Imports iTextSharp.text.pdf

Public Class PdfExport

    ' PDF export: the same report can open for printing or download as an attachment.
    Public Shared Sub Send(response As HttpResponse, report As ReportResult, fileName As String, Optional minimumRows As Integer = 0, Optional openInBrowser As Boolean = False)
        Dim bytes() As Byte
        Using stream As New MemoryStream()
            Dim document As New Document(PageSize.A4, 42, 42, 36, 36)
            PdfWriter.GetInstance(document, stream)
            document.Open()

            Dim headFont As Font = FontFactory.GetFont(FontFactory.TIMES_ROMAN, 10)
            Dim titleFont As Font = FontFactory.GetFont(FontFactory.TIMES_BOLD, 15)
            Dim subFont As Font = FontFactory.GetFont(FontFactory.TIMES_ROMAN, 11)
            Dim cellFont As Font = FontFactory.GetFont(FontFactory.TIMES_ROMAN, 10)
            Dim headerCellFont As Font = FontFactory.GetFont(FontFactory.TIMES_BOLD, 10)

            Dim banner As New PdfPTable(New Single() {60, 320, 60})
            banner.WidthPercentage = 100
            banner.HorizontalAlignment = Element.ALIGN_CENTER
            Dim barangayReport As Boolean = report.BarangayHeading IsNot Nothing
            Dim leftLogo As String = If(barangayReport, "talisay-report.png", "dilg-report.png")
            For Each item As String In New String() {leftLogo, "", "bagong-pilipinas-report.png"}
                Dim cell As New PdfPCell()
                cell.Border = Rectangle.NO_BORDER
                cell.HorizontalAlignment = Element.ALIGN_CENTER
                cell.VerticalAlignment = Element.ALIGN_MIDDLE
                If item = "" Then
                    cell.Phrase = New Phrase("Republic of the Philippines" & vbLf, headFont)
                    If barangayReport Then
                        cell.Phrase.Add(New Chunk("Barangay " & report.BarangayHeading & vbLf, headerCellFont))
                    Else
                        cell.Phrase.Add(New Chunk("Department of the Interior and Local Government" & vbLf, headerCellFont))
                        cell.Phrase.Add(New Chunk("Municipal Operations Office" & vbLf, headFont))
                    End If
                    cell.Phrase.Add(New Chunk("Talisay, Camarines Norte", headFont))
                Else
                    Dim logo As iTextSharp.text.Image = iTextSharp.text.Image.GetInstance(HttpContext.Current.Server.MapPath("~/Content/" & item))
                    logo.ScaleToFit(56, 56)
                    cell.Phrase = New Phrase(New Chunk(logo, 0, 0, True))
                End If
                banner.AddCell(cell)
            Next
            document.Add(banner)
            document.Add(New iTextSharp.text.pdf.draw.LineSeparator(0.55F, 100, BaseColor.BLACK, Element.ALIGN_CENTER, -2))
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

            Dim summary As New Paragraph(report.Summary, subFont)
            summary.SpacingAfter = 8
            document.Add(summary)

            For Each note As String In report.Notes
                Dim notePara As New Paragraph(note, subFont)
                notePara.SpacingAfter = 6
                document.Add(notePara)
            Next

            Dim output As DataTable = report.TableWithBlankRows(minimumRows)
            Dim columnCount As Integer = output.Columns.Count
            If columnCount > 0 Then
                Dim widths(columnCount - 1) As Single
                For index As Integer = 0 To widths.Length - 1
                    Select Case output.Columns(index).ColumnName
                        Case "No.", "Rank", "Late", "Score", "Priority"
                            widths(index) = 0.65F
                        Case "Activity", "Name", "Title", "Event / Activity", "Remarks", "Remarks / Reason"
                            widths(index) = 1.65F
                        Case Else
                            widths(index) = 1.15F
                    End Select
                Next
                Dim grid As New PdfPTable(widths)
                grid.WidthPercentage = 100
                For Each column As DataColumn In output.Columns
                    Dim headerCell As New PdfPCell(New Phrase(column.ColumnName, headerCellFont))
                    headerCell.BackgroundColor = BaseColor.WHITE
                    headerCell.BorderColor = BaseColor.BLACK
                    headerCell.Padding = 4
                    grid.AddCell(headerCell)
                Next
                grid.HeaderRows = 1
                For Each row As DataRow In output.Rows
                    For Each column As DataColumn In output.Columns
                        Dim text As String = If(IsDBNull(row(column)), "", Convert.ToString(row(column)))
                        Dim bodyCell As New PdfPCell(New Phrase(text, cellFont))
                        bodyCell.Padding = 4
                        bodyCell.BorderColor = BaseColor.BLACK
                        bodyCell.MinimumHeight = 19
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

            Dim footer As New PdfPTable(1) With {.WidthPercentage = 100, .KeepTogether = True, .SpacingBefore = 12}
            Dim footerCell As New PdfPCell With {.Border = Rectangle.NO_BORDER, .Padding = 0}
            footerCell.AddElement(New Paragraph("Scoring guide", headerCellFont))
            For Each line As String In ReportBuilder.ScoringGuide(report.UsesScores)
                footerCell.AddElement(New Paragraph(line, headFont))
            Next
            footer.AddCell(footerCell)

            Dim preparerCell As New PdfPCell With {.Border = Rectangle.NO_BORDER, .Padding = 0, .PaddingTop = 18}
            preparerCell.AddElement(New Paragraph("Prepared by", headerCellFont))
            Dim preparerFont As Font = FontFactory.GetFont(FontFactory.TIMES_BOLD, 10, Font.UNDERLINE)
            preparerCell.AddElement(New Paragraph(If(barangayReport, "____________________________", ReportBuilder.PreparedBy),
                                                  If(barangayReport, headFont, preparerFont)) With {.SpacingBefore = 9})
            preparerCell.AddElement(New Paragraph(If(barangayReport, "BARANGAY CAPTAIN", ReportBuilder.PreparedByTitle), headerCellFont) With {.SpacingBefore = 2})
            footer.AddCell(preparerCell)
            document.Add(footer)

            document.Close()
            bytes = stream.ToArray()
        End Using

        Dim safeName As String = fileName.Replace("""", "").Replace(vbCr, "").Replace(vbLf, "")
        response.Clear()
        response.ContentType = "application/pdf"
        response.AddHeader("Content-Disposition", If(openInBrowser, "inline", "attachment") & "; filename=""" & safeName & """")
        response.BinaryWrite(bytes)
        response.Flush()
        response.SuppressContent = True
        HttpContext.Current.ApplicationInstance.CompleteRequest()
    End Sub

End Class
