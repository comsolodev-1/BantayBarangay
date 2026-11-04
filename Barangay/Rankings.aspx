<%@ Page Title="Rankings" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Rankings.aspx.vb" Inherits="Barangay_Rankings" %>
<%@ Register Src="~/Controls/RankingsView.ascx" TagPrefix="bb" TagName="RankingsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Rankings</h1>
    <bb:RankingsView ID="rankings" runat="server" />
</asp:Content>
