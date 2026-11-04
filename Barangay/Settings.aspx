<%@ Page Title="Settings" Language="VB" MasterPageFile="~/Site.master" AutoEventWireup="false" CodeFile="Settings.aspx.vb" Inherits="Barangay_Settings" %>
<%@ Register Src="~/Controls/PasswordForm.ascx" TagPrefix="bb" TagName="PasswordForm" %>
<asp:Content ID="Content1" ContentPlaceHolderID="MainContent" runat="server">
    <p><asp:Label runat="server" Font-Size="17pt" Font-Bold="True" ForeColor="#1A3D28" role="heading" aria-level="1">Settings</asp:Label></p>
    <bb:PasswordForm ID="passwordForm" runat="server" />
</asp:Content>
