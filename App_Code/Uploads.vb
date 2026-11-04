Imports System
Imports System.Collections.Generic
Imports System.IO
Imports System.Web
Imports System.Web.UI.WebControls

Public Class Uploads

    Public Shared ReadOnly AllowedExtensions As String() = {".pdf", ".doc", ".docx", ".xls", ".xlsx", ".jpg", ".jpeg", ".png"}
    Public Const MaxBytes As Integer = 10 * 1024 * 1024

    Public Shared Function RootPath() As String
        Return HttpContext.Current.Server.MapPath("~/App_Data/uploads")
    End Function

    Private Shared Function StartsWith(bytes() As Byte, ParamArray signature() As Byte) As Boolean
        If bytes.Length < signature.Length Then Return False
        For i As Integer = 0 To signature.Length - 1
            If bytes(i) <> signature(i) Then Return False
        Next
        Return True
    End Function

    Private Shared Function SignatureMatches(extension As String, bytes() As Byte) As Boolean
        Select Case extension
            Case ".pdf"
                Return StartsWith(bytes, &H25, &H50, &H44, &H46)
            Case ".docx", ".xlsx"
                Return StartsWith(bytes, &H50, &H4B, &H3, &H4)
            Case ".doc", ".xls"
                Return StartsWith(bytes, &HD0, &HCF, &H11, &HE0)
            Case ".jpg", ".jpeg"
                Return StartsWith(bytes, &HFF, &HD8, &HFF)
            Case ".png"
                Return StartsWith(bytes, &H89, &H50, &H4E, &H47)
        End Select
        Return False
    End Function

    Public Shared Function Save(upload As FileUpload, folder As String, ByRef storedPath As String, ByRef originalName As String, ByRef errorMessage As String) As Boolean
        If upload Is Nothing OrElse Not upload.HasFile Then
            errorMessage = "Please choose a file to upload."
            Return False
        End If
        Dim name As String = Path.GetFileName(upload.FileName)
        Dim extension As String = Path.GetExtension(name).ToLowerInvariant()
        If Array.IndexOf(AllowedExtensions, extension) < 0 Then
            errorMessage = "File type not allowed. Allowed: PDF, DOC, DOCX, XLS, XLSX, JPG, PNG."
            Return False
        End If
        If upload.PostedFile.ContentLength <= 0 Then
            errorMessage = "The selected file is empty."
            Return False
        End If
        If upload.PostedFile.ContentLength > MaxBytes Then
            errorMessage = "File is too large. Maximum size is 10 MB."
            Return False
        End If
        Dim bytes() As Byte = upload.FileBytes
        If Not SignatureMatches(extension, bytes) Then
            errorMessage = "The file content does not match its file type."
            Return False
        End If
        Dim storedName As String = Guid.NewGuid().ToString("N") & extension
        Dim directoryPath As String = Path.Combine(RootPath(), folder)
        Directory.CreateDirectory(directoryPath)
        File.WriteAllBytes(Path.Combine(directoryPath, storedName), bytes)
        storedPath = folder & "/" & storedName
        If name.Length > 200 Then name = name.Substring(name.Length - 200)
        originalName = name
        Return True
    End Function

    Public Shared Function FullPath(storedPath As String) As String
        Dim root As String = Path.GetFullPath(RootPath())
        Dim full As String = Path.GetFullPath(Path.Combine(root, storedPath.Replace("/", Path.DirectorySeparatorChar)))
        If Not full.StartsWith(root, StringComparison.OrdinalIgnoreCase) Then Return Nothing
        Return full
    End Function

    Public Shared Sub Delete(storedPath As String)
        If String.IsNullOrEmpty(storedPath) Then Return
        Dim full As String = FullPath(storedPath)
        If full IsNot Nothing AndAlso File.Exists(full) Then File.Delete(full)
    End Sub

    Public Shared Function ContentTypeFor(fileName As String) As String
        Select Case Path.GetExtension(fileName).ToLowerInvariant()
            Case ".pdf" : Return "application/pdf"
            Case ".doc" : Return "application/msword"
            Case ".docx" : Return "application/vnd.openxmlformats-officedocument.wordprocessingml.document"
            Case ".xls" : Return "application/vnd.ms-excel"
            Case ".xlsx" : Return "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
            Case ".jpg", ".jpeg" : Return "image/jpeg"
            Case ".png" : Return "image/png"
        End Select
        Return "application/octet-stream"
    End Function

End Class
