Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Web
Imports System.Web.Caching
Imports System.Web.Security
Imports System.Web.SessionState
Imports System.Web.UI

Public Class Auth

    Public Const SuperAdminRole As String = "Super Admin"
    Public Const BarangayAdminRole As String = "Barangay Admin"
    Private Const MaxAttempts As Integer = 5
    Private Const LockMinutes As Integer = 15

    Public Shared ReadOnly Property IsLoggedIn As Boolean
        Get
            Return HttpContext.Current.Session("UserId") IsNot Nothing
        End Get
    End Property

    Public Shared ReadOnly Property UserId As Integer
        Get
            Dim value As Object = HttpContext.Current.Session("UserId")
            If value Is Nothing Then Return 0
            Return CInt(value)
        End Get
    End Property

    Public Shared ReadOnly Property Role As String
        Get
            Dim value As Object = HttpContext.Current.Session("Role")
            If value Is Nothing Then Return ""
            Return CStr(value)
        End Get
    End Property

    Public Shared ReadOnly Property BarangayId As Integer
        Get
            Dim value As Object = HttpContext.Current.Session("BarangayId")
            If value Is Nothing Then Return 0
            Return CInt(value)
        End Get
    End Property

    Public Shared ReadOnly Property FullName As String
        Get
            Dim value As Object = HttpContext.Current.Session("FullName")
            If value Is Nothing Then Return ""
            Return CStr(value)
        End Get
    End Property

    Public Shared ReadOnly Property BarangayName As String
        Get
            Dim value As Object = HttpContext.Current.Session("BarangayName")
            If value Is Nothing Then Return ""
            Return CStr(value)
        End Get
    End Property

    Public Shared ReadOnly Property IsSuperAdmin As Boolean
        Get
            Return Role = SuperAdminRole
        End Get
    End Property

    Public Shared Function HashPassword(password As String) As String
        Return BCrypt.Net.BCrypt.HashPassword(password, 11)
    End Function

    Public Shared Function PasswordIsStrong(password As String) As Boolean
        If password Is Nothing OrElse password.Length < 8 Then Return False
        Dim hasLetter As Boolean = False
        Dim hasDigit As Boolean = False
        For Each ch As Char In password
            If Char.IsLetter(ch) Then hasLetter = True
            If Char.IsDigit(ch) Then hasDigit = True
        Next
        Return hasLetter AndAlso hasDigit
    End Function

    Private Shared Function LockKey(username As String) As String
        Return "lock:" & username.ToLowerInvariant() & ":" & HttpContext.Current.Request.UserHostAddress
    End Function

    Public Shared Function SignIn(username As String, password As String, ByRef message As String) As Boolean
        username = If(username, "").Trim()
        Dim key As String = LockKey(username)
        Dim attempts As Integer = 0
        If HttpRuntime.Cache(key) IsNot Nothing Then attempts = CInt(HttpRuntime.Cache(key))
        If attempts >= MaxAttempts Then
            message = "Too many failed attempts. Please try again in " & LockMinutes & " minutes."
            Return False
        End If

        Dim row As DataRow = Db.QueryRow("SELECT u.user_id, u.password_hash, u.first_name, u.last_name, u.role, u.barangay_id, u.account_status, b.barangay_name, b.status AS barangay_status FROM users u LEFT JOIN barangays b ON b.barangay_id = u.barangay_id WHERE u.username = @username", "@username", username)

        Dim valid As Boolean = False
        If row IsNot Nothing AndAlso password IsNot Nothing AndAlso password.Length > 0 Then
            Try
                valid = BCrypt.Net.BCrypt.Verify(password, CStr(row("password_hash")))
            Catch
                valid = False
            End Try
        End If

        If Not valid Then
            HttpRuntime.Cache.Insert(key, attempts + 1, Nothing, DateTime.UtcNow.AddMinutes(LockMinutes), Cache.NoSlidingExpiration)
            message = "Invalid username or password."
            Return False
        End If

        If CStr(row("account_status")) <> "Active" Then
            message = "This account is not active. Please contact the DILG Talisay office."
            Return False
        End If
        If CStr(row("role")) = BarangayAdminRole AndAlso (IsDBNull(row("barangay_status")) OrElse CStr(row("barangay_status")) <> "Active") Then
            message = "This barangay is not active. Please contact the DILG Talisay office."
            Return False
        End If

        HttpRuntime.Cache.Remove(key)
        Dim session As HttpSessionState = HttpContext.Current.Session
        session.Clear()
        session("UserId") = CInt(row("user_id"))
        session("Role") = CStr(row("role"))
        session("FullName") = CStr(row("first_name")) & " " & CStr(row("last_name"))
        session("BarangayId") = If(IsDBNull(row("barangay_id")), 0, CInt(row("barangay_id")))
        session("BarangayName") = If(IsDBNull(row("barangay_name")), "", CStr(row("barangay_name")))
        Db.Execute("UPDATE users SET last_login = NOW() WHERE user_id = @id", "@id", CInt(row("user_id")))
        FormsAuthentication.SetAuthCookie(username, False)
        Return True
    End Function

    Public Shared Sub SignOut()
        HttpContext.Current.Session.Clear()
        HttpContext.Current.Session.Abandon()
        FormsAuthentication.SignOut()
    End Sub

    Public Shared Function HomeUrl() As String
        If Role = SuperAdminRole Then Return "~/Super/Dashboard.aspx"
        If Role = BarangayAdminRole Then Return "~/Barangay/Dashboard.aspx"
        Return "~/Default.aspx"
    End Function

End Class

Public Class PublicPage
    Inherits System.Web.UI.Page

    Protected Overrides Sub OnInit(e As EventArgs)
        If Session("init") Is Nothing Then Session("init") = 1
        ViewStateUserKey = Session.SessionID
        MyBase.OnInit(e)
    End Sub

End Class

Public Class SecurePage
    Inherits System.Web.UI.Page

    Protected Overridable ReadOnly Property RequiredRole As String
        Get
            Return ""
        End Get
    End Property

    Protected Overrides Sub OnInit(e As EventArgs)
        If Not Auth.IsLoggedIn OrElse (RequiredRole <> "" AndAlso Auth.Role <> RequiredRole) Then
            Auth.SignOut()
            Response.Redirect("~/Login.aspx?expired=1", True)
            Return
        End If
        Response.Cache.SetCacheability(HttpCacheability.NoCache)
        Response.Cache.SetNoStore()
        ViewStateUserKey = Session.SessionID
        MyBase.OnInit(e)
    End Sub

End Class

Public Class SuperPage
    Inherits SecurePage

    Protected Overrides ReadOnly Property RequiredRole As String
        Get
            Return Auth.SuperAdminRole
        End Get
    End Property

End Class

Public Class BarangayPage
    Inherits SecurePage

    Protected Overrides ReadOnly Property RequiredRole As String
        Get
            Return Auth.BarangayAdminRole
        End Get
    End Property

End Class
