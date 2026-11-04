<%@ Page Title="Roster" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Viewer_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Officials and Roster</h1>
    <p>Barangay and Sangguniang Kabataan officials.</p>
    <asp:Panel runat="server">
        <asp:Panel runat="server">
            <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay</asp:Label><br />
            <asp:DropDownList ID="ddlBarangay" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlBarangay_SelectedIndexChanged"></asp:DropDownList>
        </asp:Panel>
    </asp:Panel>
    <asp:Panel runat="server" SkinID="GridArea">
        <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" GridLines="None" EmptyDataText="No officials listed for this barangay.">
            <Columns>
                <asp:BoundField DataField="full_name" HeaderText="Name" />
                <asp:BoundField DataField="position" HeaderText="Position" />
                <asp:BoundField DataField="committee" HeaderText="Committee" />
            </Columns>
        </asp:GridView>
    </asp:Panel>
</asp:Content>
