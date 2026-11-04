<%@ Page Title="Announcements" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Announcements.aspx.vb" Inherits="Barangay_Announcements" %>
<%@ Register Src="~/Controls/AnnouncementsView.ascx" TagPrefix="bb" TagName="AnnouncementsView" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Announcements</h1>
    <p>Notices from the DILG Talisay office.</p>
    <bb:AnnouncementsView ID="announcements" runat="server" />
</asp:Content>
