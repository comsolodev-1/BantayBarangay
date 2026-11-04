<%@ Page Title="Reports" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Reports.aspx.vb" Inherits="Super_Reports" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Reports</h1>
    <p class="sub">Generate a report, preview it, and download it as a PDF.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    <div class="card">
        <div class="row">
            <div class="field wide">
                <label>Report</label>
                <asp:DropDownList ID="ddlReport" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReport_SelectedIndexChanged"></asp:DropDownList>
            </div>
        </div>
        <div class="row">
            <asp:Panel ID="pnlActivity" runat="server" CssClass="field wide">
                <label>Activity</label>
                <asp:DropDownList ID="ddlActivity" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlActivity_SelectedIndexChanged"></asp:DropDownList>
            </asp:Panel>
            <asp:Panel ID="pnlPeriod" runat="server" CssClass="field">
                <label>Period</label>
                <asp:DropDownList ID="ddlPeriod" runat="server"></asp:DropDownList>
            </asp:Panel>
            <asp:Panel ID="pnlBarangay" runat="server" CssClass="field">
                <label>Barangay</label>
                <asp:DropDownList ID="ddlBarangay" runat="server"></asp:DropDownList>
            </asp:Panel>
            <asp:Panel ID="pnlYear" runat="server" CssClass="field">
                <label>Year</label>
                <asp:DropDownList ID="ddlYear" runat="server"></asp:DropDownList>
            </asp:Panel>
            <asp:Panel ID="pnlMonth" runat="server" CssClass="field">
                <label>Month</label>
                <asp:DropDownList ID="ddlMonth" runat="server"></asp:DropDownList>
            </asp:Panel>
        </div>
        <asp:Button ID="btnPreview" runat="server" Text="Generate Preview" CssClass="btn" OnClick="btnPreview_Click" />
        <asp:Button ID="btnPdf" runat="server" Text="Download PDF" CssClass="btn btn-outline" OnClick="btnPdf_Click" />
    </div>
    <asp:Panel ID="pnlResult" runat="server" Visible="false" CssClass="card">
        <h2><asp:Literal ID="litTitle" runat="server"></asp:Literal></h2>
        <p class="sub"><asp:Literal ID="litSubtitle" runat="server"></asp:Literal></p>
        <asp:Literal ID="litNotes" runat="server"></asp:Literal>
        <div class="grid-wrap">
            <asp:GridView ID="gvPreview" runat="server" AutoGenerateColumns="True" CssClass="grid" GridLines="None" EmptyDataText="No records for the selected filters."></asp:GridView>
        </div>
    </asp:Panel>
</asp:Content>
