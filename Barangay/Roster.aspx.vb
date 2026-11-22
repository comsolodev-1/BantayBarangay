Imports System.Data

Partial Class Barangay_Roster
    Inherits BarangayPage

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
        txtPosition.Text = ""
        txtTermStart.Text = ""
        txtTermEnd.Text = ""
        txtCommittee.Text = ""
        txtContact.Text = ""
        txtEmail.Text = ""
        txtAddress.Text = ""
        ddlStatus.SelectedValue = "Active"
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
        If String.IsNullOrWhiteSpace(txtPosition.Text) Then missing.Add("Position")
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
            Dim changed As Integer = Db.Execute(sql, "@id", rosterId, "@b", Auth.BarangayCode, "@photo", photo,
                "@first", txtFirst.Text.Trim(), "@middle", NullIfEmpty(txtMiddle.Text), "@last", txtLast.Text.Trim(),
                "@suffix", NullIfEmpty(txtSuffix.Text), "@position", txtPosition.Text.Trim(), "@committee", NullIfEmpty(txtCommittee.Text),
                "@termStart", If(startYear = 0, Nothing, CObj(startYear)), "@termEnd", If(endYear = 0, Nothing, CObj(endYear)),
                "@contact", NullIfEmpty(txtContact.Text), "@email", NullIfEmpty(txtEmail.Text), "@address", NullIfEmpty(txtAddress.Text), "@status", ddlStatus.SelectedValue)
            If changed = 0 Then
                Uploads.Delete(photo)
                Ui.Notice(litMessage, "This official is no longer on your roster. Close the form and select an existing official.", False)
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
                txtPosition.Text = Convert.ToString(row("position"))
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
