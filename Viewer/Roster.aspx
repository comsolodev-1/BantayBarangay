<%@ Page Title="Roster" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Viewer_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Officials and Roster</asp:Label></p>
    <p>Barangay and Sangguniang Kabataan officials.</p>
    <bbui:FieldRow runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay</asp:Label><br />
            <bbui:FormSelect ID="ddlBarangay" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlBarangay_SelectedIndexChanged"></bbui:FormSelect>
        </asp:Panel>
    </bbui:FieldRow>
    <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
        <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No officials listed for this barangay.">
            <Columns>
                <asp:BoundField DataField="full_name" HeaderText="Name" />
                <asp:BoundField DataField="position" HeaderText="Position" />
                <asp:BoundField DataField="committee" HeaderText="Committee" />
            </Columns>
        </asp:GridView>
    </bbui:Card>
</asp:Content>
