Imports System
Imports System.Collections.Generic
Imports System.Web.UI
Imports System.Web.UI.WebControls

Namespace BarangayLayout
    Public NotInheritable Class RosterPosition
        Public Const BarangayGroup As String = "Barangay Officials"
        Public Const SkGroup As String = "Sangguniang Kabataan Officials"

        Public Shared ReadOnly Choices As RosterPosition() = {
            New RosterPosition(BarangayGroup, "Barangay Captain", 1, "Punong Barangay", "Kapitan"),
            New RosterPosition(BarangayGroup, "Barangay Kagawad", 7, "Kagawad"),
            New RosterPosition(BarangayGroup, "Barangay Secretary", 1),
            New RosterPosition(BarangayGroup, "Barangay Treasurer", 1),
            New RosterPosition(SkGroup, "SK Chairman", 1, "SKChairman", "SK Chairperson"),
            New RosterPosition(SkGroup, "SK Kagawad", 7),
            New RosterPosition(SkGroup, "SK Secretary", 1),
            New RosterPosition(SkGroup, "SK Treasurer", 1)
        }

        Public ReadOnly Group As String
        Public ReadOnly Name As String
        Public ReadOnly Limit As Integer
        Private ReadOnly Aliases As String()

        Private Sub New(group As String, name As String, limit As Integer, ParamArray aliases As String())
            Me.Group = group
            Me.Name = name
            Me.Limit = limit
            Me.Aliases = aliases
        End Sub

        Public Shared Function Find(value As String) As RosterPosition
            value = If(value, "").Trim()
            For Each position As RosterPosition In Choices
                If String.Equals(value, position.Name, StringComparison.OrdinalIgnoreCase) Then Return position
                For Each aliasName As String In position.Aliases
                    If String.Equals(value, aliasName, StringComparison.OrdinalIgnoreCase) Then Return position
                Next
            Next
            Return Nothing
        End Function
    End Class

    Public Class RosterPositionSelect
        Inherits FormSelect

        Public Property ActiveSeatCounts As Dictionary(Of String, Integer)

        Protected Overrides Sub OnInit(e As EventArgs)
            MyBase.OnInit(e)
            Items.Add(New ListItem("Select a position", ""))
            For Each position As RosterPosition In RosterPosition.Choices
                Items.Add(New ListItem(position.Name, position.Name))
            Next
        End Sub

        Protected Overrides Sub RenderContents(writer As HtmlTextWriter)
            Dim group As String = Nothing
            For Each item As ListItem In Items
                Dim position As RosterPosition = RosterPosition.Find(item.Value)
                Dim nextGroup As String = If(position Is Nothing, Nothing, position.Group)
                If group <> nextGroup Then
                    If group IsNot Nothing Then writer.RenderEndTag()
                    group = nextGroup
                    If group IsNot Nothing Then
                        writer.AddAttribute("label", group)
                        writer.RenderBeginTag("optgroup")
                    End If
                End If

                Dim caption As String = item.Text
                Dim used As Integer = 0
                If position IsNot Nothing AndAlso ActiveSeatCounts IsNot Nothing Then
                    ActiveSeatCounts.TryGetValue(position.Name, used)
                    Dim available As Integer = position.Limit - used
                    If available <= 0 AndAlso Not item.Selected Then
                        writer.AddAttribute("disabled", "disabled")
                        caption &= " (full)"
                    ElseIf position.Limit > 1 AndAlso available > 0 Then
                        caption &= " (" & available.ToString() & " available)"
                    End If
                End If
                Page.ClientScript.RegisterForEventValidation(UniqueID, item.Value)
                writer.AddAttribute("value", item.Value)
                If item.Selected Then writer.AddAttribute("selected", "selected")
                writer.RenderBeginTag("option")
                writer.WriteEncodedText(caption)
                writer.RenderEndTag()
            Next
            If group IsNot Nothing Then writer.RenderEndTag()
        End Sub
    End Class
End Namespace
