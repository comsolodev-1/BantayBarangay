<%@ Page Title="Reports" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Reports.aspx.vb" Inherits="Super_Reports" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Reports</asp:Label></p>
    <p>Generate a report, preview it, and download it as a PDF.</p>
    <asp:Literal ID="litMessage" runat="server"></asp:Literal>
    <bbui:Card runat="server">
        <bbui:FieldRow runat="server">
            <asp:Panel runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlReport" Font-Bold="True">Report</asp:Label><br />
                <bbui:FormSelect ID="ddlReport" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlReport_SelectedIndexChanged"></bbui:FormSelect>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:FieldRow runat="server">
            <asp:Panel ID="pnlActivity" runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlActivity" Font-Bold="True">Activity</asp:Label><br />
                <bbui:FormSelect ID="ddlActivity" runat="server" AutoPostBack="true" OnSelectedIndexChanged="ddlActivity_SelectedIndexChanged"></bbui:FormSelect>
            </asp:Panel>
            <asp:Panel ID="pnlPeriod" runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlPeriod" Font-Bold="True">Period</asp:Label><br />
                <bbui:FormSelect ID="ddlPeriod" runat="server"></bbui:FormSelect>
            </asp:Panel>
            <asp:Panel ID="pnlBarangay" runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlBarangay" Font-Bold="True">Barangay</asp:Label><br />
                <bbui:FormSelect ID="ddlBarangay" runat="server"></bbui:FormSelect>
            </asp:Panel>
            <asp:Panel ID="pnlYear" runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlYear" Font-Bold="True">Year</asp:Label><br />
                <bbui:FormSelect ID="ddlYear" runat="server"></bbui:FormSelect>
            </asp:Panel>
            <asp:Panel ID="pnlMonth" runat="server">
                <asp:Label runat="server" AssociatedControlID="ddlMonth" Font-Bold="True">Month</asp:Label><br />
                <bbui:FormSelect ID="ddlMonth" runat="server"></bbui:FormSelect>
            </asp:Panel>
        </bbui:FieldRow>
        <bbui:ActionButton ID="btnPreview" runat="server" Text="Generate Preview" OnClick="btnPreview_Click" />
        <bbui:ActionButton ID="btnPdf" runat="server" Text="Download PDF" SkinID="Secondary" OnClick="btnPdf_Click" />
    </bbui:Card>
    <bbui:Card ID="pnlResult" runat="server" Visible="false">
        <p><asp:Label runat="server" Font-Size="12pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="2"><asp:Literal ID="litTitle" runat="server"></asp:Literal></asp:Label></p>
        <p><asp:Literal ID="litSubtitle" runat="server"></asp:Literal></p>
        <asp:Literal ID="litNotes" runat="server"></asp:Literal>
        <bbui:Card runat="server" ContentPadding="0" CornerSize="6" SeparateAfter="false">
            <asp:GridView ID="gvPreview" runat="server" AutoGenerateColumns="True" GridLines="None" EmptyDataText="No records for the selected filters."></asp:GridView>
        </bbui:Card>
    </bbui:Card>
</asp:Content>
