<%@ Page Title="Important Dates" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="ImportantDates.aspx.vb" Inherits="Barangay_ImportantDates" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Important Dates</asp:Label></p>
    <p>Dates visible to your barangay and public activity deadlines.</p>
    <bbui:Card runat="server">
    <asp:Calendar ID="calEvents" runat="server" Width="100%" DayStyle-Height="92px" DayStyle-VerticalAlign="Top" CellPadding="4" ShowGridLines="True" OnDayRender="calEvents_DayRender" NextPrevFormat="ShortMonth" DayNameFormat="Short">
        <TitleStyle BackColor="#1a5c38" ForeColor="White" Font-Bold="True" Height="34px" />
        <OtherMonthDayStyle ForeColor="#b5c4bb" />
        <TodayDayStyle BackColor="#fef9e7" />
    </asp:Calendar>
    </bbui:Card>
</asp:Content>
