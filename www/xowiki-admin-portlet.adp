
Manage Pages of <a href='@applet_url@'>XoWiki</a>
<if @package_id@ eq "">
  <small>No community specified</small>
</if>
<else>
<ul>
<multiple name="content">
  <li>
    @content.pretty_name@<small> <a class="button" href="@applet_url@admin/portal-element-remove?element_id=@content.element_id@&referer=@referer@&portal_id=@template_portal_id@">#acs-subsite.Delete#</a></small>
  </li>
</multiple>
</ul>
@form;noquote@
</else>
