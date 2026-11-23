Imports System.Data
Imports BarangayLayout
Imports MySql.Data.MySqlClient

Partial Class Barangay_Roster
    Inherits BarangayPage

    Private Const ActiveSeatsSql As String =
        "SELECT position, COUNT(*) AS occupied FROM barangay_roster " &
        "WHERE barangay_code = @b AND status = 'Active' AND roster_id <> @id GROUP BY position"

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then BindRoster()
    End Sub

    Private Sub BindRoster()
        roster.BindRoster(Auth.BarangayCode)
    End Sub

    Private Sub ClearForm()
        hfRosterId.Value = "0"
        txtFirst.Text = ""
        txtMiddle.Text = ""
        txtLast.Text = ""
        txtSuffix.Text = ""
        SelectPosition("")
        txtTermStart.Text = ""
        txtTermEnd.Text = ""
        txtCommittee.Text = ""
        txtContact.Text = ""
        txtEmail.Text = ""
        txtAddress.Text = ""
        ddlStatus.SelectedValue = "Active"
    End Sub

    Private Sub SelectPosition(storedValue As String)
        Dim last As ListItem = ddlPosition.Items(ddlPosition.Items.Count - 1)
        If RosterPosition.Find(last.Value) Is Nothing AndAlso last.Value <> "" Then ddlPosition.Items.Remove(last)

        Dim position As RosterPosition = RosterPosition.Find(storedValue)
        If position IsNot Nothing Then
            ddlPosition.SelectedValue = position.Name
        Else
            If storedValue <> "" Then ddlPosition.Items.Add(New ListItem(storedValue & " (existing)", storedValue))
            ddlPosition.SelectedValue = storedValue
        End If
    End Sub

    Private Shared Function CountActiveSeats(rows As DataTable) As Dictionary(Of String, Integer)
        Dim counts As New Dictionary(Of String, Integer)(StringComparer.OrdinalIgnoreCase)
        For Each row As DataRow In rows.Rows
            Dim position As RosterPosition = RosterPosition.Find(Convert.ToString(row("position")))
            If position Is Nothing Then Continue For
            Dim used As Integer
            counts.TryGetValue(position.Name, used)
            counts(position.Name) = used + CInt(row("occupied"))
        Next
        Return counts
    End Function

    Protected Sub Page_PreRender(sender As Object, e As EventArgs) Handles Me.PreRender
        If Not pnlForm.Visible OrElse ddlStatus.SelectedValue <> "Active" Then Return
        Dim rosterId As Integer
        If Not Integer.TryParse(hfRosterId.Value, rosterId) Then Return
        ddlPosition.ActiveSeatCounts = CountActiveSeats(Db.Query(ActiveSeatsSql, "@b", Auth.BarangayCode, "@id", rosterId))
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        ClearForm()
        litFormTitle.Text = "Add Official"
        pnlForm.Visible = True
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        pnlForm.Visible = False
    End Sub

    Private Shared Function NullIfEmpty(value As String) As Object
        If value Is Nothing OrElse value.Trim().Length = 0 Then Return Nothing
        Return value.Trim()
    End Function

    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        Dim missing As New List(Of String)
        If String.IsNullOrWhiteSpace(txtFirst.Text) Then missing.Add("First name")
        If String.IsNullOrWhiteSpace(txtLast.Text) Then missing.Add("Last name")
        If String.IsNullOrWhiteSpace(ddlPosition.SelectedValue) Then missing.Add("Position")
        Dim startText As String = txtTermStart.Text.Trim()
        Dim endText As String = txtTermEnd.Text.Trim()
        If startText = "" AndAlso endText <> "" Then missing.Add("Start year")
        If endText = "" AndAlso startText <> "" Then missing.Add("End year")
        If missing.Count > 0 Then
            Ui.Notice(litMessage, "Unable to save official information. Complete the following " &
                      If(missing.Count = 1, "field", "fields") & ": " & String.Join(", ", missing) & ".", False)
            Return
        End If
        ' Roster term years: when an official has a term, save both the start and end year.
        Dim startYear As Integer
        Dim endYear As Integer
        If startText <> "" Then
            If startText.Length <> 4 OrElse Not Integer.TryParse(startText, startYear) OrElse startYear < 1000 Then
                Ui.Notice(litMessage, "Enter a four-digit start year for the term of service.", False)
                Return
            End If
            If endText.Length <> 4 OrElse Not Integer.TryParse(endText, endYear) OrElse endYear < 1000 Then
                Ui.Notice(litMessage, "Enter a four-digit end year for the term of service.", False)
                Return
            End If
            If endYear < startYear Then
                Ui.Notice(litMessage, "The end year must be on or after the start year.", False)
                Return
            End If
        End If
        Dim rosterId As Integer
        If Not Integer.TryParse(hfRosterId.Value, rosterId) OrElse rosterId < 0 Then Return
        Dim photo As String = Nothing
        If fuPhoto.HasFile Then
            Dim extension As String = System.IO.Path.GetExtension(fuPhoto.FileName).ToLowerInvariant()
            If extension <> ".jpg" AndAlso extension <> ".jpeg" AndAlso extension <> ".png" Then
                Ui.Notice(litMessage, "Choose a JPG or PNG portrait.", False)
                Return
            End If
            Dim originalName As String = Nothing, uploadError As String = Nothing
            If Not Uploads.Save(fuPhoto, "portraits", photo, originalName, uploadError) Then
                Ui.Notice(litMessage, uploadError, False)
                Return
            End If
        End If
        Try
            Dim sql As String = If(rosterId = 0,
                "INSERT INTO barangay_roster (photo_path, barangay_code, first_name, middle_name, last_name, suffix, position, committee, term_start_year, term_end_year, contact_number, email, address, status, date_activated) VALUES (@photo, @b, @first, @middle, @last, @suffix, @position, @committee, @termStart, @termEnd, @contact, @email, @address, @status, IF(@status = 'Active', NOW(), NULL))",
                "UPDATE barangay_roster SET photo_path = COALESCE(@photo, photo_path), first_name = @first, middle_name = @middle, last_name = @last, suffix = @suffix, position = @position, committee = @committee, term_start_year = @termStart, term_end_year = @termEnd, contact_number = @contact, email = @email, address = @address, status = @status, date_modified = NOW() WHERE roster_id = @id AND barangay_code = @b")
            Dim saveError As String = Nothing
            Dim barangay As String = Auth.BarangayCode
            Dim selectedPosition As String = ddlPosition.SelectedValue
            Dim status As String = ddlStatus.SelectedValue
            Db.InTransaction(Sub(tx)
                ' Roster seat limits: lock this barangay before counting seats and saving the official.
                If Db.TxScalar(tx, "SELECT barangay_code FROM barangays WHERE barangay_code = @b FOR UPDATE", "@b", barangay) Is Nothing Then
                    saveError = "This barangay is no longer available."
                    Return
                End If
                Dim existing As DataRow = Nothing
                If rosterId <> 0 Then
                    existing = Db.TxRow(tx, "SELECT position, status FROM barangay_roster WHERE roster_id = @id AND barangay_code = @b FOR UPDATE", "@id", rosterId, "@b", barangay)
                    If existing Is Nothing Then
                        saveError = "This official is no longer on your roster. Close the form and select an existing official."
                        Return
                    End If
                End If
                Dim oldPosition As String = If(existing Is Nothing, "", Convert.ToString(existing("position")))
                Dim wasActive As Boolean = existing IsNot Nothing AndAlso Convert.ToString(existing("status")) = "Active"
                Dim position As RosterPosition = RosterPosition.Find(selectedPosition)
                If position Is Nothing Then
                    If rosterId = 0 OrElse selectedPosition <> oldPosition OrElse (status = "Active" AndAlso Not wasActive) Then
                        saveError = "Choose a listed position for this official."
                        Return
                    End If
                ElseIf status = "Active" AndAlso Not (wasActive AndAlso RosterPosition.Find(oldPosition) Is position) Then
                    Dim counts As Dictionary(Of String, Integer) =
                        CountActiveSeats(Db.TxQuery(tx, ActiveSeatsSql, "@b", barangay, "@id", rosterId))
                    Dim used As Integer
                    counts.TryGetValue(position.Name, used)
                    If used >= position.Limit Then
                        saveError = "All active seats for " & position.Name & " are filled in your barangay. Choose another position or mark the outgoing official inactive."
                        Return
                    End If
                End If
                Db.TxExecute(tx, sql, "@id", rosterId, "@b", barangay, "@photo", photo,
                    "@first", txtFirst.Text.Trim(), "@middle", NullIfEmpty(txtMiddle.Text), "@last", txtLast.Text.Trim(),
                    "@suffix", NullIfEmpty(txtSuffix.Text), "@position", If(position Is Nothing, oldPosition, position.Name), "@committee", NullIfEmpty(txtCommittee.Text),
                    "@termStart", If(startYear = 0, Nothing, CObj(startYear)), "@termEnd", If(endYear = 0, Nothing, CObj(endYear)),
                    "@contact", NullIfEmpty(txtContact.Text), "@email", NullIfEmpty(txtEmail.Text), "@address", NullIfEmpty(txtAddress.Text), "@status", status)
            End Sub)
            If saveError IsNot Nothing Then
                Uploads.Delete(photo)
                Ui.Notice(litMessage, saveError, False)
                Return
            End If
            Ui.Notice(litMessage, If(rosterId = 0, "Official added.", "Official updated."), True)
        Catch ex As Exception
            Uploads.Delete(photo)
            Ui.Notice(litMessage, "The official could not be saved. Please try again.", False)
            Return
        End Try
        pnlForm.Visible = False
        BindRoster()
    End Sub

    Protected Sub gvRoster_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim rosterId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), rosterId) Then Return
        Select Case e.CommandName
            Case "EditRow"
                Dim row As DataRow = Db.QueryRow("SELECT * FROM barangay_roster WHERE roster_id = @id AND barangay_code = @b", "@id", rosterId, "@b", Auth.BarangayCode)
                If row Is Nothing Then Return
                hfRosterId.Value = rosterId.ToString()
                txtMiddle.Text = Convert.ToString(row("middle_name"))
                txtFirst.Text = Convert.ToString(row("first_name"))
                txtLast.Text = Convert.ToString(row("last_name"))
                txtSuffix.Text = Convert.ToString(row("suffix"))
                SelectPosition(Convert.ToString(row("position")))
                txtTermStart.Text = Convert.ToString(row("term_start_year"))
                txtTermEnd.Text = Convert.ToString(row("term_end_year"))
                txtCommittee.Text = Convert.ToString(row("committee"))
                txtContact.Text = Convert.ToString(row("contact_number"))
                txtEmail.Text = Convert.ToString(row("email"))
                txtAddress.Text = Convert.ToString(row("address"))
                ddlStatus.SelectedValue = Convert.ToString(row("status"))
                litFormTitle.Text = "Edit Official"
                pnlForm.Visible = True
            Case "DeleteRow"
                Db.Execute("DELETE FROM barangay_roster WHERE roster_id = @id AND barangay_code = @b", "@id", rosterId, "@b", Auth.BarangayCode)
                Ui.Notice(litMessage, "Official deleted.", True)
                BindRoster()
        End Select
    End Sub

End Class
