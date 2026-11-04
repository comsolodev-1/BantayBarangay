Imports System.Data

Partial Class Barangay_Roster
    Inherits BarangayPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If Not IsPostBack Then BindRoster()
    End Sub

    Private Sub BindRoster()
        gvRoster.DataSource = Db.Query("SELECT roster_id, CONCAT(first_name, ' ', COALESCE(CONCAT(LEFT(middle_name, 1), '. '), ''), last_name, COALESCE(CONCAT(' ', suffix), '')) AS full_name, position, committee, contact_number, status FROM barangay_roster WHERE barangay_id = @b ORDER BY last_name, first_name", "@b", Auth.BarangayId)
        gvRoster.DataBind()
    End Sub

    Private Sub ClearForm()
        hfRosterId.Value = "0"
        txtFirst.Text = ""
        txtMiddle.Text = ""
        txtLast.Text = ""
        txtSuffix.Text = ""
        txtPosition.Text = ""
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
        If txtFirst.Text.Trim().Length = 0 OrElse txtLast.Text.Trim().Length = 0 OrElse txtPosition.Text.Trim().Length = 0 Then
            Ui.Notice(litMessage, "First name, last name and position are required.", False)
            Return
        End If
        Dim rosterId As Integer = CInt(hfRosterId.Value)
        If rosterId = 0 Then
            Db.Execute("INSERT INTO barangay_roster (barangay_id, first_name, middle_name, last_name, suffix, position, committee, contact_number, email, address, status, date_activated) VALUES (@b, @first, @middle, @last, @suffix, @position, @committee, @contact, @email, @address, @status, IF(@status = 'Active', NOW(), NULL))",
                       "@b", Auth.BarangayId, "@first", txtFirst.Text.Trim(), "@middle", NullIfEmpty(txtMiddle.Text), "@last", txtLast.Text.Trim(), "@suffix", NullIfEmpty(txtSuffix.Text), "@position", txtPosition.Text.Trim(), "@committee", NullIfEmpty(txtCommittee.Text), "@contact", NullIfEmpty(txtContact.Text), "@email", NullIfEmpty(txtEmail.Text), "@address", NullIfEmpty(txtAddress.Text), "@status", ddlStatus.SelectedValue)
            Ui.Notice(litMessage, "Official added.", True)
        Else
            Db.Execute("UPDATE barangay_roster SET first_name = @first, middle_name = @middle, last_name = @last, suffix = @suffix, position = @position, committee = @committee, contact_number = @contact, email = @email, address = @address, status = @status, date_modified = NOW() WHERE roster_id = @id AND barangay_id = @b",
                       "@first", txtFirst.Text.Trim(), "@middle", NullIfEmpty(txtMiddle.Text), "@last", txtLast.Text.Trim(), "@suffix", NullIfEmpty(txtSuffix.Text), "@position", txtPosition.Text.Trim(), "@committee", NullIfEmpty(txtCommittee.Text), "@contact", NullIfEmpty(txtContact.Text), "@email", NullIfEmpty(txtEmail.Text), "@address", NullIfEmpty(txtAddress.Text), "@status", ddlStatus.SelectedValue, "@id", rosterId, "@b", Auth.BarangayId)
            Ui.Notice(litMessage, "Official updated.", True)
        End If
        pnlForm.Visible = False
        BindRoster()
    End Sub

    Protected Sub gvRoster_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim rosterId As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), rosterId) Then Return
        Select Case e.CommandName
            Case "EditRow"
                Dim row As DataRow = Db.QueryRow("SELECT * FROM barangay_roster WHERE roster_id = @id AND barangay_id = @b", "@id", rosterId, "@b", Auth.BarangayId)
                If row Is Nothing Then Return
                hfRosterId.Value = rosterId.ToString()
                txtMiddle.Text = Convert.ToString(row("middle_name"))
                txtFirst.Text = Convert.ToString(row("first_name"))
                txtLast.Text = Convert.ToString(row("last_name"))
                txtSuffix.Text = Convert.ToString(row("suffix"))
                txtPosition.Text = Convert.ToString(row("position"))
                txtCommittee.Text = Convert.ToString(row("committee"))
                txtContact.Text = Convert.ToString(row("contact_number"))
                txtEmail.Text = Convert.ToString(row("email"))
                txtAddress.Text = Convert.ToString(row("address"))
                ddlStatus.SelectedValue = Convert.ToString(row("status"))
                litFormTitle.Text = "Edit Official"
                pnlForm.Visible = True
            Case "DeleteRow"
                Db.Execute("DELETE FROM barangay_roster WHERE roster_id = @id AND barangay_id = @b", "@id", rosterId, "@b", Auth.BarangayId)
                Ui.Notice(litMessage, "Official deleted.", True)
                BindRoster()
        End Select
    End Sub

End Class
