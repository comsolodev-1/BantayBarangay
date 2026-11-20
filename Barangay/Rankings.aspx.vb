Partial Class Barangay_Rankings
    Inherits BarangayPage

    Protected Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        rankings.HighlightBarangayCode = Auth.BarangayCode
    End Sub

End Class
