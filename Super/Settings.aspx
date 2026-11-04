<%@ Page Title="Settings" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Settings.aspx.vb" Inherits="Super_Settings" %>
<%@ Register Src="~/Controls/PasswordForm.ascx" TagPrefix="bb" TagName="PasswordForm" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <h1>Settings</h1>
    <bb:PasswordForm ID="passwordForm" runat="server" />
</asp:Content>
