Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Globalization
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace BarangayLayout
    Public Class RecordPager
        Inherits WebControl
        Implements IPostBackEventHandler

        Public Const PageSize As Integer = 20
        Public Event PageChanged As EventHandler
        Public Property ShowSinglePageSummary As Boolean

        Public Property PageIndex As Integer
            Get
                Return If(ViewState("Index") Is Nothing, 0, CInt(ViewState("Index")))
            End Get
            Set(value As Integer)
                ViewState("Index") = Math.Max(0, value)
            End Set
        End Property

        Private ReadOnly Property RecordCount As Integer
            Get
                Return If(ViewState("Count") Is Nothing, 0, CInt(ViewState("Count")))
            End Get
        End Property

        Private ReadOnly Property PageCount As Integer
            Get
                Return Math.Max(1, CInt(Math.Ceiling(RecordCount / CDbl(PageSize))))
            End Get
        End Property

        Private Sub SetCount(count As Integer)
            ViewState("Count") = count
            PageIndex = Math.Min(PageIndex, PageCount - 1)
        End Sub

        ' Record pagination. Count the filtered rows and fetch just the requested page.
        Public Function ReadPage(columns As String, source As String, orderBy As String, ParamArray args() As Object) As DataTable
            SetCount(Db.ScalarInt("SELECT COUNT(*) " & source, args))
            Dim pageArgs As New List(Of Object)(args)
            pageArgs.AddRange(New Object() {"@pageSize", PageSize, "@pageOffset", PageIndex * PageSize})
            Return Db.Query("SELECT " & columns & " " & source & " ORDER BY " & orderBy &
                            " LIMIT @pageSize OFFSET @pageOffset", pageArgs.ToArray())
        End Function

        Public Function Slice(data As DataTable) As DataTable
            SetCount(data.Rows.Count)
            Dim result As DataTable = data.Clone()
            For index As Integer = PageIndex * PageSize To Math.Min((PageIndex + 1) * PageSize, RecordCount) - 1
                result.ImportRow(data.Rows(index))
            Next
            Return result
        End Function

        Private Sub RaisePostBackEvent(eventArgument As String) Implements IPostBackEventHandler.RaisePostBackEvent
            Dim postedValue As String = Page.Request.Form(UniqueID)
            If String.IsNullOrEmpty(postedValue) Then Return
            Page.ClientScript.ValidateEvent(UniqueID, postedValue)
            Dim target As Integer
            If Not Integer.TryParse(postedValue, NumberStyles.None, CultureInfo.InvariantCulture, target) OrElse
                target < 0 OrElse target >= PageCount OrElse target = PageIndex Then Return
            PageIndex = target
            RaiseEvent PageChanged(Me, EventArgs.Empty)
        End Sub

        Protected Overrides Sub Render(writer As HtmlTextWriter)
            If PageCount <= 1 AndAlso Not ShowSinglePageSummary Then Return
            writer.AddAttribute("aria-label", "Record pages")
            writer.RenderBeginTag("nav")
            writer.AddAttribute("role", "status")
            writer.RenderBeginTag("p")
            Dim first As Integer = If(RecordCount > 0, PageIndex * PageSize + 1, 0)
            Dim last As Integer = Math.Min((PageIndex + 1) * PageSize, RecordCount)
            writer.WriteEncodedText(String.Format("{0:N0}" & ChrW(&H2013) & "{1:N0} of {2:N0} records " &
                                                  ChrW(&HB7) & " Page {3:N0} of {4:N0}",
                                                   first, last, RecordCount, PageIndex + 1, PageCount))
            writer.RenderEndTag()

            If PageCount > 1 Then
                WriteButton(writer, "Previous", PageIndex - 1, PageIndex > 0)
                Dim start As Integer = Math.Max(0, Math.Min(PageIndex - 2, PageCount - 5))
                Dim finish As Integer = Math.Min(PageCount - 1, start + 4)
                If start > 0 Then WriteNumber(writer, 0)
                If start > 1 Then writer.Write("&#8230; ")
                For target As Integer = start To finish
                    WriteNumber(writer, target)
                Next
                If finish < PageCount - 2 Then writer.Write("&#8230; ")
                If finish < PageCount - 1 Then WriteNumber(writer, PageCount - 1)
                WriteButton(writer, "Next", PageIndex + 1, PageIndex + 1 < PageCount)
            End If
            writer.RenderEndTag()
        End Sub

        Private Sub WriteNumber(writer As HtmlTextWriter, target As Integer)
            Dim caption As String = (target + 1).ToString(CultureInfo.InvariantCulture)
            writer.AddAttribute("aria-label", "Page " & caption)
            If target = PageIndex Then writer.AddAttribute("aria-current", "page")
            WriteButton(writer, caption, target, target <> PageIndex)
        End Sub

        Private Sub WriteButton(writer As HtmlTextWriter, caption As String, target As Integer, enabled As Boolean)
            ActionAppearance.Write(writer)
            writer.AddAttribute("type", "submit")
            If enabled Then
                Dim value As String = target.ToString(CultureInfo.InvariantCulture)
                Page.ClientScript.RegisterForEventValidation(UniqueID, value)
                writer.AddAttribute("name", UniqueID)
                writer.AddAttribute("value", value)
            Else
                writer.AddAttribute("disabled", "disabled")
            End If
            writer.RenderBeginTag("button")
            writer.WriteEncodedText(caption)
            writer.RenderEndTag()
            writer.Write(" ")
        End Sub
    End Class
End Namespace
