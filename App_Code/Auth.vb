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
    ' Login-page lock-out (per browser, not per account): every 3rd failure in a row locks the
    ' login for 1, then 5, then 15 minutes; the 12th failure starts the cycle again at 1 minute.
    Private Const FailuresPerLock As Integer = 3
    Private Shared ReadOnly LockSteps As Integer() = {1, 5, 15}

    Public Shared ReadOnly Property IsLoggedIn As Boolean
        Get
            Dim context As HttpContext = HttpContext.Current
            Dim session As HttpSessionState = context.Session
            If session Is Nothing OrElse session("UserId") Is Nothing Then Return False
            If context.Items("ValidAccountSession") IsNot Nothing Then
                Return CBool(context.Items("ValidAccountSession"))
            End If

            Dim current As DataRow = Db.QueryRow(
                "SELECT u.session_version, u.account_status, r.role_name, b.status AS barangay_status " &
                "FROM users u JOIN roles r ON r.role_id = u.role_id " &
                "LEFT JOIN barangays b ON b.barangay_code = u.barangay_code WHERE u.user_id = @id",
                "@id", CInt(session("UserId")))
            Dim valid As Boolean = current IsNot Nothing AndAlso
                CStr(current("account_status")) = "Active" AndAlso
                CStr(current("role_name")) = CStr(session("Role")) AndAlso
                session("AccountVersion") IsNot Nothing AndAlso CULng(current("session_version")) = CULng(session("AccountVersion")) AndAlso
                (CStr(current("role_name")) <> BarangayAdminRole OrElse
                 Convert.ToString(current("barangay_status")) = "Active")
            context.Items("ValidAccountSession") = valid
            If Not valid Then SignOut()
            Return valid
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

    Public Shared ReadOnly Property BarangayCode As String
        Get
            Return Convert.ToString(HttpContext.Current.Session("BarangayCode"))
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

    ' Each browser gets a random id cookie; the lock-out is tracked per browser, so people sharing
    ' one network (same public IP) do not lock each other out.
    Private Shared Function ClientId() As String
        Dim ctx As HttpContext = HttpContext.Current
        Dim id As String = TryCast(ctx.Items("ClientId"), String)
        If id IsNot Nothing Then Return id
        Dim cookie As HttpCookie = ctx.Request.Cookies("bb_client")
        If cookie IsNot Nothing AndAlso System.Text.RegularExpressions.Regex.IsMatch(cookie.Value, "^[0-9a-f]{32}$") Then
            id = cookie.Value
        Else
            id = Guid.NewGuid().ToString("N")
            Dim fresh As New HttpCookie("bb_client", id)
            fresh.HttpOnly = True
            fresh.Expires = DateTime.UtcNow.AddDays(30)
            ctx.Response.Cookies.Add(fresh)
        End If
        ctx.Items("ClientId") = id
        Return id
    End Function

    Private Shared Function LockKey(prefix As String) As String
        Return prefix & ":" & ClientId()
    End Function

    ' Seconds left on the login lock for this visitor (0 = login is open).
    Public Shared Function LoginLockSeconds() As Integer
        Dim until As Object = HttpRuntime.Cache(LockKey("until"))
        If until Is Nothing Then Return 0
        Return Math.Max(0, CInt(Math.Ceiling(CType(until, DateTime).Subtract(DateTime.UtcNow).TotalSeconds)))
    End Function

    Public Shared Function LockMessage() As String
        Dim minutes As Integer = Math.Max(1, CInt(Math.Ceiling(LoginLockSeconds() / 60.0)))
        Return "Too many failed attempts. Please try again in " & minutes & If(minutes = 1, " minute.", " minutes.")
    End Function

    ' Seconds left on the lock raised by the last SignIn call on this request (0 = not locked).
    Public Shared ReadOnly Property LockSeconds As Integer
        Get
            Dim value As Object = HttpContext.Current.Items("LockSeconds")
            If value Is Nothing Then Return 0
            Return CInt(value)
        End Get
    End Property

    Public Shared Function SignIn(username As String, password As String, ByRef message As String) As Boolean
        username = If(username, "").Trim()
        Dim locked As Integer = LoginLockSeconds()
        If locked > 0 Then
            HttpContext.Current.Items("LockSeconds") = locked
            message = LockMessage()
            Return False
        End If

        Dim row As DataRow = Db.QueryRow("SELECT u.user_id, u.password_hash, u.session_version, u.username, r.role_name AS role, u.barangay_code, u.account_status, b.barangay_name, b.status AS barangay_status FROM users u JOIN roles r ON r.role_id = u.role_id LEFT JOIN barangays b ON b.barangay_code = u.barangay_code WHERE u.username = @username", "@username", username)

        Dim valid As Boolean = False
        If row IsNot Nothing AndAlso password IsNot Nothing AndAlso password.Length > 0 Then
            Try
                valid = BCrypt.Net.BCrypt.Verify(password, CStr(row("password_hash")))
            Catch
                valid = False
            End Try
        End If

        If Not valid Then
            Dim failKey As String = LockKey("fails")
            Dim fails As Integer = 1
            If HttpRuntime.Cache(failKey) IsNot Nothing Then fails = CInt(HttpRuntime.Cache(failKey)) + 1
            HttpRuntime.Cache.Insert(failKey, fails, Nothing, Cache.NoAbsoluteExpiration, TimeSpan.FromHours(24))
            If fails Mod FailuresPerLock = 0 Then
                Dim minutes As Integer = LockSteps(((fails \ FailuresPerLock) - 1) Mod LockSteps.Length)
                Dim expires As DateTime = DateTime.UtcNow.AddMinutes(minutes)
                HttpRuntime.Cache.Insert(LockKey("until"), expires, Nothing, expires, Cache.NoSlidingExpiration)
                HttpContext.Current.Items("LockSeconds") = minutes * 60
                message = LockMessage()
            Else
                message = "Invalid username or password."
            End If
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

        Db.InTransaction(Sub(tx)
            Db.TxExecute(tx, "UPDATE users SET last_login = NOW() WHERE user_id = @id", "@id", row("user_id"))
            Db.TxExecute(tx, "INSERT INTO audit_log (performed_by_user_id, barangay_code, action_name, entity_name, record_id, details) VALUES (@id,@b,'Signed in','users',@id,'Successful sign-in')", "@id", row("user_id"), "@b", row("barangay_code"))
        End Sub)
        HttpRuntime.Cache.Remove(LockKey("fails"))
        HttpRuntime.Cache.Remove(LockKey("until"))
        Dim session As HttpSessionState = HttpContext.Current.Session
        session.Clear()
        HttpContext.Current.Items.Remove("ValidAccountSession")
        session("UserId") = CInt(row("user_id"))
        session("AccountVersion") = CULng(row("session_version"))
        session("Role") = CStr(row("role"))
        session("FullName") = CStr(row("username"))
        session("BarangayCode") = Convert.ToString(row("barangay_code"))
        session("BarangayName") = If(IsDBNull(row("barangay_name")), "", CStr(row("barangay_name")))

        FormsAuthentication.SetAuthCookie(username, False)
        Return True
    End Function

    Public Shared Sub SignOut()
        HttpContext.Current.Items("ValidAccountSession") = False
        HttpContext.Current.Session.Clear()
        HttpContext.Current.Session.Abandon()
        FormsAuthentication.SignOut()
    End Sub

    Public Shared Function HomeUrl() As String
        If Role = SuperAdminRole Then Return "~/Super/Dashboard.aspx"
        If Role = BarangayAdminRole Then Return "~/Barangay/Dashboard.aspx"
        Return "~/Viewer/Dashboard.aspx"
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
