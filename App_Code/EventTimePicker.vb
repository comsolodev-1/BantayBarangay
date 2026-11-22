Imports System.Globalization
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace BarangayLayout
    ' Important Dates time slots. Post HH:mm through the same Text property the save handler reads.
    Public Class EventTimePicker
        Inherits TextBox

        Public Property FirstAllowedMinute As Integer
        Public Property EmptyCaption As String = "No time selected"

        Protected Overrides Sub Render(writer As HtmlTextWriter)
            Page.ClientScript.RegisterForEventValidation(UniqueID)
            writer.AddAttribute("id", ClientID)
            writer.AddAttribute("name", UniqueID)
            If AutoPostBack Then
                Dim options As New PostBackOptions(Me, "") With {.AutoPostBack = True}
                writer.AddAttribute("onchange", Page.ClientScript.GetPostBackEventReference(options, True))
            End If
            FieldAppearance.Write(writer)
            ControlStyle.AddAttributesToRender(writer, Me)
            writer.RenderBeginTag("select")
            writer.AddAttribute("value", "")
            writer.RenderBeginTag("option")
            writer.WriteEncodedText(EmptyCaption)
            writer.RenderEndTag()
            Dim culture As CultureInfo = CultureInfo.InvariantCulture
            For hour As Integer = 0 To 23
                Dim hourStart As DateTime = DateTime.MinValue.AddHours(hour)
                writer.AddAttribute("label", hourStart.ToString("h tt", culture))
                writer.RenderBeginTag("optgroup")
                For minute As Integer = 0 To 59
                    Dim slot As DateTime = hourStart.AddMinutes(minute)
                    Dim value As String = slot.ToString("HH:mm", culture)
                    writer.AddAttribute("value", value)
                    Dim unavailable As Boolean = hour * 60 + minute < FirstAllowedMinute
                    If unavailable AndAlso value <> Text Then writer.AddAttribute("disabled", "disabled")
                    If value = Text Then writer.AddAttribute("selected", "selected")
                    writer.RenderBeginTag("option")
                    writer.Write(slot.ToString("h:mm tt", culture))
                    If unavailable AndAlso value = Text Then writer.Write(" (unavailable)")
                    writer.RenderEndTag()
                Next
                writer.RenderEndTag()
            Next
            writer.RenderEndTag()
        End Sub
    End Class
End Namespace
