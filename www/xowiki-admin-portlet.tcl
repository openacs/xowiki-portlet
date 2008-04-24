ad_page_contract {
    The display logic for the xowiki admin portlet
    
    @author Michael Totschnig
    @author Gustaf Neumann
    @cvs_id $Id$
} {
  package_id:optional
  template_portal_id:optional
  referer:optional
  return_url:optional
}

if {[exists_and_not_null package_id]} {
  set xowiki_package_id $package_id
} elseif {[info exists cf]} {
  array set config $cf
  set xowiki_package_id $config(package_id)
} else {
  ns_return 500 text/html "No package_id for XoWiki provided"
  ad_script_abort
}

::xowiki::Package initialize -package_id $xowiki_package_id
set applet_url [::$xowiki_package_id package_url]

if {![exists_and_not_null template_portal_id]} {
  set template_portal_id [dotlrn_community::get_portal_id]
}
  
if {![info exists referer] && [exists_and_not_null return_url]} {
  set referer $return_url
}
  
if {![info exists referer]} {
  set referer [ad_conn url]
}
  
set element_pretty_name [parameter::get \
			     -parameter xowiki_admin_portlet_element_pretty_name \
			     -default [_ xowiki-portlet.admin_portlet_element_pretty_name]]
  
db_multirow content select_content \
      "select m.element_id, m.pretty_name, pep.value as name 
	  from portal_element_map m, portal_pages p, portal_element_parameters pep
          where m.page_id = p.page_id 
          and p.portal_id = $template_portal_id 
          and m.datasource_id = [portal::get_datasource_id [xowiki_portlet name]]
          and pep.element_id = m.element_id and pep.key = 'page_name'" {}
  
# don't ask to insert same page twice
template::multirow foreach content {set used_page_id($name) 1}

set options ""
db_foreach instance_select \
    [::xowiki::Page instance_select_query \
	 -folder_id [::$xowiki_package_id folder_id] \
	 -with_subtypes true \
	 -from_clause ", xowiki_page P" \
	 -where_clause "P.page_id = bt.revision_id" \
	 -orderby "ci.name" \
	] {
	  if {[regexp {^::[0-9]} $name]} continue
	  if {[info exists used_page_id($name)]} continue
	  append options "<option value=\"$name\">$name</option>"
	}



if {$options ne ""} {
  set form [subst {
    <form name="new_xowiki_element" method="post" action="${applet_url}admin/portal-element-add">
    <input type="hidden" name="portal_id" value="$template_portal_id">
    <input type="hidden" name="referer" value="$referer">
    #xowiki-portlet.new_xowiki_admin_portlet# <select name="page_name" id="new_xowiki_element_page_id">
    $options
    </select>
    <input type="submit" name="formbutton:ok" value="       OK       " id="new_xowiki_element_formbutton:ok" />
    </form>
  }]
} else {
  set form "All pages already used"
}


