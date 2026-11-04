<%@ Page Title="Roster" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Roster.aspx.vb" Inherits="Viewer_Roster" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Officials and Roster</h1>
    <p class="sub">Barangay and Sangguniang Kabataan officials.</p>
    <div class="row">
        <div class="field">
            <label>Barangay</label>
            <asp:DropDownList ID="ddlBarangay" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlBarangay_SelectedIndexChanged"></asp:DropDownList>
        </div>
    </div>
    <div class="grid-wrap">
        <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" CssClass="grid" GridLines="None" EmptyDataText="No officials listed for this barangay.">
            <Columns>
                <asp:BoundField DataField="full_name" HeaderText="Name" />
                <asp:BoundField DataField="position" HeaderText="Position" />
                <asp:BoundField DataField="committee" HeaderText="Committee" />
            </Columns>
        </asp:GridView>
    </div>
</asp:Content>
