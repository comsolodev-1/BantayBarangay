<%@ Page Title="Calendar" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Calendar.aspx.vb" Inherits="Viewer_Calendar" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Calendar</h1>
    <p class="sub">Important dates and public activity deadlines.</p>
    <asp:Calendar ID="calEvents" runat="server" CssClass="calendar-table" ShowGridLines="False" OnDayRender="calEvents_DayRender" NextPrevFormat="ShortMonth" DayNameFormat="Short">
        <TitleStyle BackColor="#1a5c38" ForeColor="White" Font-Bold="True" Height="34px" />
        <OtherMonthDayStyle ForeColor="#b5c4bb" />
        <TodayDayStyle BackColor="#fef9e7" />
    </asp:Calendar>
</asp:Content>
