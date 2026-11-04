Partial Class Barangay_Rankings
    Inherits BarangayPage

    Protected Sub Page_Init(sender As Object, e As EventArgs) Handles Me.Init
        rankings.HighlightBarangayId = Auth.BarangayId
    End Sub

End Class
