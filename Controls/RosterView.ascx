<%@ Control Language="VB" AutoEventWireup="false" CodeFile="RosterView.ascx.vb" Inherits="RosterView" %>
<bbui:Card runat="server" CssClass="roster-table" ContentPadding="0" SeparateAfter="false">
    <bbui:DataGrid ID="gvRoster" runat="server" AutoGenerateColumns="False" GridLines="None" ShowHeaderWhenEmpty="True"
        OnRowCommand="gvRoster_RowCommand" EmptyDataText="No officials match this selection.">
        <Columns>
            <asp:TemplateField HeaderText="Photo">
                <ItemTemplate>
                    <asp:PlaceHolder runat="server" Visible='<%# Not String.IsNullOrWhiteSpace(Convert.ToString(Eval("photo_path"))) %>'>
                        <button type="button" popovertarget='<%# "portrait_" & Eval("roster_id").ToString() %>'
                            aria-label='View portrait of <%#: Eval("full_name") %>' style="padding:0;border:0;background:transparent;cursor:pointer">
                            <asp:Image runat="server" Width="44px" Height="44px" style="object-fit:cover;border-radius:50%" AlternateText="" GenerateEmptyAlternateText="True" ImageUrl='<%# "~/Download.aspx?t=portrait&id=" & Eval("roster_id").ToString() %>' />
                        </button>
                        <div id='<%# "portrait_" & Eval("roster_id").ToString() %>' popover="auto" role="dialog" aria-label="Official profile"
                            style="width:min(480px,85vw);padding:16px;text-align:center;border:1px solid #86a793;border-radius:8px">
                            <asp:Image runat="server" loading="lazy" AlternateText="Official portrait" style="max-width:100%;max-height:48vh;object-fit:contain" ImageUrl='<%# "~/Download.aspx?t=portrait&id=" & Eval("roster_id").ToString() %>' />
                            <h2><%#: Eval("full_name") %></h2>
                            <p><%#: Eval("position") %></p>
                            <button type="button" popovertarget='<%# "portrait_" & Eval("roster_id").ToString() %>' popovertargetaction="hide">Close</button>
                        </div>
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
                    <bbui:ActionLink runat="server" CommandName="EditRow" CommandArgument='<%# Eval("roster_id") %>' CausesValidation="false">Edit</bbui:ActionLink>
                    <bbui:ActionLink runat="server" SkinID="Danger" CommandName="DeleteRow" CommandArgument='<%# Eval("roster_id") %>'
                        CausesValidation="false" data-confirm="Delete this official?">Delete</bbui:ActionLink>
                </ItemTemplate>
            </asp:TemplateField>
        </Columns>
    </bbui:DataGrid>
</bbui:Card>
<bbui:RecordPager ID="pager" runat="server" OnPageChanged="Pager_PageChanged" />
