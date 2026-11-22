Imports System
Imports System.Collections.Generic
Imports System.Data
Imports System.Configuration
Imports MySql.Data.MySqlClient

Public Class Db
    Public Sub New()

    End Sub

    Public Shared Function NewConnection() As MySqlConnection
        Dim settings As New MySqlConnectionStringBuilder(ConfigurationManager.ConnectionStrings("BantayDb").ConnectionString)
        settings.AllowUserVariables = True
        Return New MySqlConnection(settings.ConnectionString)
    End Function

    Private Shared Sub AddParameters(cmd As MySqlCommand, args() As Object)
        If args Is Nothing Then Return
        Dim i As Integer = 0
        While i + 1 < args.Length
            Dim value As Object = args(i + 1)
            If value Is Nothing Then value = DBNull.Value
            cmd.Parameters.AddWithValue(CStr(args(i)), value)
            i += 2
        End While
    End Sub

    Public Shared Function Query(sql As String, ParamArray args() As Object) As DataTable
        Dim result As New DataTable()
        Using conn As MySqlConnection = NewConnection()
            Using cmd As New MySqlCommand(sql, conn)
                AddParameters(cmd, args)
                Using adapter As New MySqlDataAdapter(cmd)
                    adapter.Fill(result)
                End Using
            End Using
        End Using
        Return result
    End Function

    Public Shared Function QueryRow(sql As String, ParamArray args() As Object) As DataRow
        Dim table As DataTable = Query(sql, args)
        If table.Rows.Count = 0 Then Return Nothing
        Return table.Rows(0)
    End Function

    Public Shared Function Scalar(sql As String, ParamArray args() As Object) As Object
        Using conn As MySqlConnection = NewConnection()
            conn.Open()
            Using cmd As New MySqlCommand(sql, conn)
                AddParameters(cmd, args)
                Dim value As Object = cmd.ExecuteScalar()
                If value Is Nothing OrElse value Is DBNull.Value Then Return Nothing
                Return value
            End Using
        End Using
    End Function

    Public Shared Function ScalarInt(sql As String, ParamArray args() As Object) As Integer
        Dim value As Object = Scalar(sql, args)
        If value Is Nothing Then Return 0
        Return Convert.ToInt32(value)
    End Function

    Private Shared Sub OpenWriteConnection(conn As MySqlConnection)
        conn.Open()
        Dim ctx = System.Web.HttpContext.Current
        Dim signedIn = ctx IsNot Nothing AndAlso ctx.Items("Housekeeping") Is Nothing AndAlso ctx.Session IsNot Nothing AndAlso Auth.IsLoggedIn
        Using cmd As New MySqlCommand("SET @performed_by_user_id = @uid", conn)
            cmd.Parameters.AddWithValue("@uid", If(signedIn, CObj(Auth.UserId), DBNull.Value))
            cmd.ExecuteNonQuery()
        End Using
    End Sub

    Public Shared Function Execute(sql As String, ParamArray args() As Object) As Integer
        Using conn As MySqlConnection = NewConnection()
            OpenWriteConnection(conn)
            Using cmd As New MySqlCommand(sql, conn)
                AddParameters(cmd, args)
                Return cmd.ExecuteNonQuery()
            End Using
        End Using
    End Function

    Public Shared Function Insert(sql As String, ParamArray args() As Object) As Long
        Using conn As MySqlConnection = NewConnection()
            OpenWriteConnection(conn)
            Using cmd As New MySqlCommand(sql, conn)
                AddParameters(cmd, args)
                cmd.ExecuteNonQuery()
                Return cmd.LastInsertedId
            End Using
        End Using
    End Function

    Public Shared Function TxExecute(tx As MySqlTransaction, sql As String, ParamArray args() As Object) As Long
        Using cmd As New MySqlCommand(sql, tx.Connection, tx)
            AddParameters(cmd, args)
            cmd.ExecuteNonQuery()
            Return cmd.LastInsertedId
        End Using
    End Function

    Public Shared Function TxScalar(tx As MySqlTransaction, sql As String, ParamArray args() As Object) As Object
        Using cmd As New MySqlCommand(sql, tx.Connection, tx)
            AddParameters(cmd, args)
            Return cmd.ExecuteScalar()
        End Using
    End Function

    Public Shared Function TxRow(tx As MySqlTransaction, sql As String, ParamArray args() As Object) As DataRow
        Using cmd As New MySqlCommand(sql, tx.Connection, tx)
            AddParameters(cmd, args)
            Using reader As MySqlDataReader = cmd.ExecuteReader()
                Dim table As New DataTable()
                table.Load(reader)
                If table.Rows.Count = 0 Then Return Nothing
                Return table.Rows(0)
            End Using
        End Using
    End Function

    Public Shared Sub InTransaction(work As Action(Of MySqlTransaction))
        Using conn As MySqlConnection = NewConnection()
            OpenWriteConnection(conn)
            Using tx As MySqlTransaction = conn.BeginTransaction()
                Try
                    work(tx)
                    tx.Commit()
                Catch
                    tx.Rollback()
                    Throw
                End Try
            End Using
        End Using
    End Sub

    Public Shared Sub Housekeeping()
        Dim ctx = System.Web.HttpContext.Current
        ctx.Items("Housekeeping") = True
        Try
            PeriodHelper.EnsureScheduledPeriods()
            Execute("UPDATE reporting_period p JOIN activities a ON a.activity_id = p.activity_id " &
                    "SET p.period_status = " & PeriodHelper.StatusSql & ", p.date_closed = IF(" & PeriodHelper.CutoffSql & " < NOW(), COALESCE(p.date_closed, " & PeriodHelper.CutoffSql & "), NULL) " &
                    "WHERE a.activity_status <> 'Archived' AND p.submission_deadline IS NOT NULL AND p.period_status <> (" & PeriodHelper.StatusSql & ")")
            Execute("UPDATE activities a LEFT JOIN (SELECT DISTINCT p.activity_id FROM reporting_period p WHERE " &
                    PeriodHelper.AcceptsSubmissionSql & ") accepting ON accepting.activity_id = a.activity_id " &
                    "SET a.activity_status = IF(accepting.activity_id IS NULL, 'Closed', 'Active') " &
                    "WHERE a.activity_status <> 'Archived' AND a.activity_status <> IF(accepting.activity_id IS NULL, 'Closed', 'Active')")
            Execute("UPDATE announcements SET status = 'Archived' WHERE status = 'Published' AND expiration_date IS NOT NULL AND expiration_date < NOW()")
            Execute("UPDATE important_dates SET status = 'Past' WHERE status = 'Upcoming' AND event_date < CURDATE()")
        Finally
            ctx.Items.Remove("Housekeeping")
        End Try
    End Sub

    Protected Overrides Sub Finalize()
        MyBase.Finalize()
    End Sub
End Class
