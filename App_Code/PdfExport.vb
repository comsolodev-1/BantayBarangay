Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.IO
Imports System.Web
Imports iTextSharp.text
Imports iTextSharp.text.pdf

Public Class PdfExport

    Public Shared Sub Send(response As HttpResponse, report As ReportResult, fileName As String)
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

            Dim line1 As New Paragraph("Republic of the Philippines", headFont)
            line1.Alignment = Element.ALIGN_CENTER
            document.Add(line1)
            Dim line2 As New Paragraph("DILG Municipal Office of Talisay, Camarines Norte", headFont)
            line2.Alignment = Element.ALIGN_CENTER
            document.Add(line2)
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

            Dim columnCount As Integer = report.Table.Columns.Count
            If columnCount > 0 Then
                Dim grid As New PdfPTable(columnCount)
                grid.WidthPercentage = 100
                For Each column As DataColumn In report.Table.Columns
                    Dim headerCell As New PdfPCell(New Phrase(column.ColumnName, headerCellFont))
                    headerCell.BackgroundColor = New BaseColor(230, 242, 236)
                    headerCell.Padding = 5
                    grid.AddCell(headerCell)
                Next
                grid.HeaderRows = 1
                For Each row As DataRow In report.Table.Rows
                    For Each column As DataColumn In report.Table.Columns
                        Dim text As String = If(IsDBNull(row(column)), "", Convert.ToString(row(column)))
                        Dim bodyCell As New PdfPCell(New Phrase(text, cellFont))
                        bodyCell.Padding = 4
                        grid.AddCell(bodyCell)
                    Next
                Next
                If report.Table.Rows.Count = 0 Then
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
