Imports System.Data

Partial Class Super_Announcements
    Inherits SuperPage

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        If IsPostBack Then Return
        Ui.Fill(ddlTargetBarangay, Db.Query("SELECT barangay_id, barangay_name FROM barangays WHERE status = 'Active' ORDER BY barangay_name"), "barangay_name", "barangay_id")
        BindGrid()
    End Sub

    Private Sub BindGrid()
        gvAnnouncements.DataSource = Db.Query("SELECT announcement_id, title, priority, visibility_type, date_published, status, is_pinned FROM announcements ORDER BY date_created DESC")
        gvAnnouncements.DataBind()
    End Sub

    Private Sub ClearForm()
        hfId.Value = "0"
        txtTitle.Text = ""
        txtContent.Text = ""
        ddlPriority.SelectedValue = "Medium"
        ddlVisibility.SelectedValue = "All"
        ddlStatus.SelectedValue = "Published"
        txtExpiration.Text = ""
        chkPinned.Checked = False
        litCurrentFile.Text = ""
    End Sub

    Protected Sub btnNew_Click(sender As Object, e As EventArgs)
        ClearForm()
        litFormTitle.Text = "New Announcement"
        pnlForm.Visible = True
    End Sub

    Protected Sub btnCancel_Click(sender As Object, e As EventArgs)
        pnlForm.Visible = False
    End Sub

    Protected Sub btnSave_Click(sender As Object, e As EventArgs)
        If txtTitle.Text.Trim().Length = 0 OrElse txtContent.Text.Trim().Length = 0 Then
            Ui.Notice(litMessage, "Title and content are required.", False)
            Return
        End If
        If ddlVisibility.SelectedValue = "Specific Barangay" AndAlso ddlTargetBarangay.Items.Count = 0 Then
            Ui.Notice(litMessage, "Choose a target barangay.", False)
            Return
        End If

        Dim expiration As Object = Nothing
        Dim expirationValue As DateTime
        If txtExpiration.Text.Trim().Length > 0 Then
            If Not DateTime.TryParse(txtExpiration.Text, expirationValue) Then
                Ui.Notice(litMessage, "Expiration date is not valid.", False)
                Return
            End If
            expiration = PeriodHelper.EndOfDay(expirationValue)
        End If

        Dim filePath As String = Nothing
        Dim fileName As String = Nothing
        Dim errorMessage As String = ""
        If fuAttachment.HasFile Then
            If Not Uploads.Save(fuAttachment, "announcements", filePath, fileName, errorMessage) Then
                Ui.Notice(litMessage, errorMessage, False)
                Return
            End If
        End If

        Dim targetRole As Object = Nothing
        Dim targetBarangay As Object = Nothing
        If ddlVisibility.SelectedValue = "Specific Role" Then targetRole = ddlRole.SelectedValue
        If ddlVisibility.SelectedValue = "Specific Barangay" Then targetBarangay = CInt(ddlTargetBarangay.SelectedValue)
        Dim pinned As Integer = If(chkPinned.Checked, 1, 0)
        Dim id As Integer = CInt(hfId.Value)

        Try
            If id = 0 Then
                Db.Execute("INSERT INTO announcements (title, content, attachment_file_name, attachment_file_path, created_by, date_published, expiration_date, priority, status, visibility_type, target_role, target_barangay_id, is_pinned) VALUES (@title, @content, @fname, @fpath, @user, IF(@status = 'Published', NOW(), NULL), @expiration, @priority, @status, @visibility, @role, @barangay, @pinned)",
                           "@title", txtTitle.Text.Trim(), "@content", txtContent.Text.Trim(), "@fname", fileName, "@fpath", filePath, "@user", Auth.UserId, "@expiration", expiration, "@priority", ddlPriority.SelectedValue, "@status", ddlStatus.SelectedValue, "@visibility", ddlVisibility.SelectedValue, "@role", targetRole, "@barangay", targetBarangay, "@pinned", pinned)
                Ui.Notice(litMessage, "Announcement saved.", True)
            Else
                Dim old As DataRow = Db.QueryRow("SELECT attachment_file_path FROM announcements WHERE announcement_id = @id", "@id", id)
                If old Is Nothing Then
                    Uploads.Delete(filePath)
                    Return
                End If
                Db.Execute("UPDATE announcements SET title = @title, content = @content, expiration_date = @expiration, priority = @priority, status = @status, visibility_type = @visibility, target_role = @role, target_barangay_id = @barangay, is_pinned = @pinned, date_published = IF(@status = 'Published' AND date_published IS NULL, NOW(), date_published), date_modified = NOW() WHERE announcement_id = @id",
                           "@title", txtTitle.Text.Trim(), "@content", txtContent.Text.Trim(), "@expiration", expiration, "@priority", ddlPriority.SelectedValue, "@status", ddlStatus.SelectedValue, "@visibility", ddlVisibility.SelectedValue, "@role", targetRole, "@barangay", targetBarangay, "@pinned", pinned, "@id", id)
                If filePath IsNot Nothing Then
                    Db.Execute("UPDATE announcements SET attachment_file_name = @fname, attachment_file_path = @fpath WHERE announcement_id = @id", "@fname", fileName, "@fpath", filePath, "@id", id)
                    If Not IsDBNull(old("attachment_file_path")) Then Uploads.Delete(CStr(old("attachment_file_path")))
                End If
                Ui.Notice(litMessage, "Announcement updated.", True)
            End If
        Catch
            Uploads.Delete(filePath)
            Ui.Notice(litMessage, "The announcement could not be saved. Please try again.", False)
            Return
        End Try
        pnlForm.Visible = False
        BindGrid()
    End Sub

    Protected Sub gvAnnouncements_RowCommand(sender As Object, e As GridViewCommandEventArgs)
        Dim id As Integer
        If Not Integer.TryParse(Convert.ToString(e.CommandArgument), id) Then Return
        Dim row As DataRow = Db.QueryRow("SELECT * FROM announcements WHERE announcement_id = @id", "@id", id)
        If row Is Nothing Then Return
        Select Case e.CommandName
            Case "EditRow"
                ClearForm()
                hfId.Value = id.ToString()
                txtTitle.Text = Convert.ToString(row("title"))
                txtContent.Text = Convert.ToString(row("content"))
                If Not IsDBNull(row("priority")) Then ddlPriority.SelectedValue = Convert.ToString(row("priority"))
                ddlVisibility.SelectedValue = Convert.ToString(row("visibility_type"))
                ddlStatus.SelectedValue = Convert.ToString(row("status"))
                If Not IsDBNull(row("expiration_date")) Then txtExpiration.Text = Convert.ToDateTime(row("expiration_date")).ToString("yyyy-MM-dd")
                chkPinned.Checked = Convert.ToInt32(row("is_pinned")) = 1
                If Not IsDBNull(row("target_barangay_id")) AndAlso ddlTargetBarangay.Items.FindByValue(row("target_barangay_id").ToString()) IsNot Nothing Then ddlTargetBarangay.SelectedValue = row("target_barangay_id").ToString()
                If Not IsDBNull(row("attachment_file_name")) Then litCurrentFile.Text = "<small>Current file: " & Ui.H(row("attachment_file_name")) & " (upload a new file to replace it)</small>"
                litFormTitle.Text = "Edit Announcement"
                pnlForm.Visible = True
            Case "DeleteRow"
                Db.Execute("DELETE FROM announcements WHERE announcement_id = @id", "@id", id)
                If Not IsDBNull(row("attachment_file_path")) Then Uploads.Delete(CStr(row("attachment_file_path")))
                Ui.Notice(litMessage, "Announcement deleted.", True)
                BindGrid()
        End Select
    End Sub

End Class
