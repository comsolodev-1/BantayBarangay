<%@ Page Title="Calendar" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Calendar.aspx.vb" Inherits="Viewer_Calendar" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Calendar</asp:Label></p>
    <p>Important dates, public activity deadlines, and announcement publication dates.</p>
    <!-- The calendar fills the available viewer area. -->
    <bbui:Card runat="server" CssClass="viewer-calendar">
        <asp:Calendar
            ID="calEvents"
            runat="server"
            Width="100%"
            DayStyle-VerticalAlign="Top"
            CellPadding="4"
            ShowGridLines="True"
            OnDayRender="calEvents_DayRender"
            NextPrevFormat="ShortMonth"
            DayNameFormat="Short">
            <TitleStyle BackColor="#1a5c38" ForeColor="White" Font-Bold="True" Height="34px" />
            <OtherMonthDayStyle ForeColor="#b5c4bb" />
            <TodayDayStyle BackColor="#fef9e7" />
        </asp:Calendar>
    </bbui:Card>
</asp:Content>
