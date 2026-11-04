<%@ Page Title="Rankings" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Rankings.aspx.vb" Inherits="Super_Rankings" %>
<%@ Register Src="~/Controls/RankingsView.ascx" TagPrefix="bb" TagName="RankingsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Rankings</asp:Label></p>
    <bb:RankingsView ID="rankings" runat="server" />
</asp:Content>
