<%@ Page Title="Announcements" Language="VB" MasterPageFile="~/Public.master" AutoEventWireup="false" CodeFile="Announcements.aspx.vb" Inherits="Viewer_Announcements" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Announcements</h1>
    <p>Notices and important information from the DILG Talisay office.</p>
    <bb:AnnouncementsView ID="announcements" runat="server" />
</asp:Content>
