<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RosterView.ascx.vb" Inherits="RosterView" %>
<bbui:Card runat="server" CssClass="roster-table" ContentPadding="0" SeparateAfter="false">
    <asp:GridView ID="gvRoster" runat="server" AutoGenerateColumns="False" GridLines="None" ShowHeaderWhenEmpty="True"
        OnRowCommand="gvRoster_RowCommand" EmptyDataText="No officials match this selection.">
        <Columns>
            <asp:TemplateField HeaderText="Photo">
                <ItemTemplate>
                    <asp:PlaceHolder runat="server" Visible='<%# Not String.IsNullOrWhiteSpace(Convert.ToString(Eval("photo_path"))) %>'>
                        <a class="portrait-link" href='<%# ResolveUrl("~/Download.aspx") & "?t=portrait&amp;id=" & Eval("roster_id").ToString() %>'
                            data-portrait-name='<%#: Eval("full_name") %>' data-portrait-position='<%#: Eval("position") %>'
                            aria-label='View portrait of <%#: Eval("full_name") %>'>
                            <asp:Image runat="server" CssClass="portrait" AlternateText="" GenerateEmptyAlternateText="True" ImageUrl='<%# "~/Download.aspx?t=portrait&id=" & Eval("roster_id").ToString() %>' />
                        </a>
                    </asp:PlaceHolder>
                    <asp:PlaceHolder runat="server" Visible='<%# String.IsNullOrWhiteSpace(Convert.ToString(Eval("photo_path"))) %>'>&mdash;</asp:PlaceHolder>
                </ItemTemplate>
            </asp:TemplateField>
            <asp:BoundField DataField="full_name" HeaderText="Name" />
            <asp:BoundField DataField="barangay_name" HeaderText="Barangay" />
            <asp:BoundField DataField="position" HeaderText="Position" />
            <asp:BoundField DataField="committee" HeaderText="Committee" />
            <asp:BoundField DataField="term_of_service" HeaderText="Term of Service" NullDisplayText="—" />
            <asp:TemplateField HeaderText="Status">
                <ItemTemplate><%# Ui.Badge(Eval("status")) %></ItemTemplate>
            </asp:TemplateField>
            <asp:TemplateField HeaderText="Actions" Visible="False">
                <ItemTemplate>
                    <asp:LinkButton runat="server" CommandName="EditRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false">Edit</asp:LinkButton>
                    <asp:LinkButton runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("roster_id") %>'
                        CausesValidation="false" data-confirm="Delete this official?">Delete</asp:LinkButton>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </asp:GridView>
</bbui:Card>
<dialog class="workflow-dialog portrait-dialog" data-portrait-dialog aria-labelledby="portrait-dialog-title">
    <header class="modal-title">
        <span id="portrait-dialog-title">Official profile</span>
        <button type="button" data-dialog-close aria-label="Close official profile">&times;</button>
    </header>
    <div class="portrait-content">
        <img alt="" />
        <h2 data-official-name></h2>
        <p data-official-position></p>
    </div>
</dialog>
