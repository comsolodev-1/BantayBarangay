<%@ Page Title="Announcements" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Announcements.aspx.vb" Inherits="Viewer_Announcements" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Announcements</asp:Label></p>
    <p>Notices and important information from the DILG Talisay office.</p>
    <bb:AnnouncementsView ID="announcements" runat="server" />
</asp:Content>
