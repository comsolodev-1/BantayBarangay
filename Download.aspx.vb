Imports System.Data
Imports System.IO

Partial Class DownloadPage
    Inherits System.Web.UI.Page

    Private Sub Deny()
        Response.StatusCode = 404
        Response.Write("File not found.")
        Context.ApplicationInstance.CompleteRequest()
    End Sub

    Protected Sub Page_Load(sender As Object, e As EventArgs) Handles Me.Load
        Dim kind As String = If(Request.QueryString("t"), "")
        Dim id As Integer
        If Not Integer.TryParse(Request.QueryString("id"), id) Then
            Deny()
            Return
        End If

        Dim storedPath As String = Nothing
        Dim displayName As String = Nothing

        Select Case kind
            Case "submission", "denial"
                If Not Auth.IsLoggedIn Then
                    Deny()
                    Return
                End If
                Dim row As DataRow = Db.QueryRow("SELECT file_name, file_path, denial_attachment, barangay_id FROM submissions WHERE date_id = @id", "@id", id)
                If row Is Nothing Then
                    Deny()
                    Return
                End If
                If Not Auth.IsSuperAdmin AndAlso CInt(row("barangay_id")) <> Auth.BarangayId Then
                    Deny()
                    Return
                End If
                If kind = "submission" Then
                    storedPath = CStr(row("file_path"))
                    displayName = CStr(row("file_name"))
                ElseIf Not IsDBNull(row("denial_attachment")) Then
                    storedPath = CStr(row("denial_attachment"))
                    displayName = "denial-attachment" & Path.GetExtension(storedPath)
                End If

            Case "template"
                Dim row As DataRow = Db.QueryRow("SELECT template_file_name, template_link, is_public FROM activities WHERE activity_id = @id", "@id", id)
                If row Is Nothing OrElse IsDBNull(row("template_link")) Then
                    Deny()
                    Return
                End If
                Dim allowed As Boolean = Convert.ToInt32(row("is_public")) = 1
                If Auth.IsLoggedIn Then
                    If Auth.IsSuperAdmin Then
                        allowed = True
                    ElseIf Db.ScalarInt("SELECT COUNT(*) FROM activity_barangays WHERE activity_id = @a AND barangay_id = @b", "@a", id, "@b", Auth.BarangayId) > 0 Then
                        allowed = True
                    End If
                End If
                If Not allowed Then
                    Deny()
                    Return
                End If
                storedPath = CStr(row("template_link"))
                displayName = CStr(row("template_file_name"))

            Case "announcement"
                Dim row As DataRow = Db.QueryRow("SELECT attachment_file_name, attachment_file_path, visibility_type, target_role, target_barangay_id FROM announcements WHERE announcement_id = @id AND status = 'Published'", "@id", id)
                If row Is Nothing OrElse IsDBNull(row("attachment_file_path")) Then
                    Deny()
                    Return
                End If
                Dim allowed As Boolean = CStr(row("visibility_type")) = "All"
                If Auth.IsLoggedIn AndAlso Not allowed Then
                    If Auth.IsSuperAdmin Then
                        allowed = True
                    ElseIf CStr(row("visibility_type")) = "Specific Role" AndAlso Not IsDBNull(row("target_role")) AndAlso CStr(row("target_role")) = Auth.Role Then
                        allowed = True
                    ElseIf CStr(row("visibility_type")) = "Specific Barangay" AndAlso Not IsDBNull(row("target_barangay_id")) AndAlso CInt(row("target_barangay_id")) = Auth.BarangayId Then
                        allowed = True
                    End If
                End If
                If Not allowed Then
                    Deny()
                    Return
                End If
                storedPath = CStr(row("attachment_file_path"))
                displayName = CStr(row("attachment_file_name"))
        End Select

        If String.IsNullOrEmpty(storedPath) Then
            Deny()
            Return
        End If
        Dim fullPath As String = Uploads.FullPath(storedPath)
        If fullPath Is Nothing OrElse Not File.Exists(fullPath) Then
            Deny()
            Return
        End If

        Dim safeName As String = displayName.Replace("""", "").Replace(vbCr, "").Replace(vbLf, "")
        Response.Clear()
        Response.ContentType = Uploads.ContentTypeFor(safeName)
        Response.AddHeader("Content-Disposition", "attachment; filename=""" & safeName & """")
        Response.AddHeader("X-Content-Type-Options", "nosniff")
        Response.TransmitFile(fullPath)
        Response.Flush()
        Context.ApplicationInstance.CompleteRequest()
    End Sub

End Class
