ad_library {
  Procedures to supports xowiki admin portlets.

  @creation-date 2008-02-26
  @author Gustaf Neumann
  @cvs-id $Id$
}

#
# This is the first approach to make the portlet-procs
#
#  (a) in an oo-style (the object below contains everything
#      for the management of the portlet) and
#  (b) independent from the database layer
#      (supposed to work under postgres and Oracle)
#
# In the next steps, it would make sense to define a ::dotlrn::Portlet
# class, which provides some of the common behavior defined here...
#
Object xowiki_admin_portlet
xowiki_admin_portlet proc name {} {
  return "xowiki-admin-portlet"
}

xowiki_admin_portlet proc pretty_name {} {
  return [parameter::get_from_package_key \
              -package_key [:package_key] \
              -parameter xowiki_admin_portlet_pretty_name]
}

xowiki_admin_portlet proc package_key {} {
  return "xowiki-portlet"
}

xowiki_admin_portlet proc link {} {
  return ""
}

xowiki_admin_portlet ad_proc add_self_to_page {
  {-portal_id:required}
  {-package_id:required}
} {
  Adds an xowiki admin PE to the given portal
} {
  return [portal::add_element_parameters \
              -portal_id $portal_id \
              -portlet_name [:name] \
              -key package_id \
              -value $package_id \
             ]
  ns_log notice "end of add_self_to_page"
}

xowiki_admin_portlet ad_proc remove_self_from_page {
  {-portal_id:required}
} {
  Removes xowiki admin PE from the given page
} {
  # This is easy since there's one and only one instace_id
  portal::remove_element \
      -portal_id $portal_id \
      -portlet_name [:name]
}

xowiki_admin_portlet ad_proc show {
  cf
} {
  Display the xowiki admin PE
} {
  portal::show_proc_helper \
      -package_key [:package_key] \
      -config_list $cf \
      -template_src "xowiki-admin-portlet"
}

xowiki_admin_portlet proc install {} {
  :log "--portlet calling [self proc]"
  set name [:name]
  db_transaction {

    #
    # create the datasource
    #
    set ds_id [portal::datasource::new \
                   -name $name \
                   -description "Displays the admin interface for the xowiki data portlets"]

    # default configuration
    portal::datasource::set_def_param -datasource_id $ds_id \
        -config_required_p t -configured_p t \
        -key "shadeable_p" -value f

    portal::datasource::set_def_param -datasource_id $ds_id \
        -config_required_p t -configured_p t \
        -key "shaded_p" -value f

    portal::datasource::set_def_param -datasource_id $ds_id \
        -config_required_p t -configured_p t \
        -key "hideable_p" -value t

    portal::datasource::set_def_param -datasource_id $ds_id \
        -config_required_p t -configured_p t \
        -key "user_editable_p" -value f

    portal::datasource::set_def_param -datasource_id $ds_id \
        -config_required_p t -configured_p t \
        -key "link_hideable_p" -value t

    # xowiki-admin-specific procs

    # package_id must be configured
    portal::datasource::set_def_param -datasource_id $ds_id \
        -config_required_p t -configured_p f \
        -key "package_id" -value ""


    #
    # service contract managemet
    #
    # create the implementation
    acs_sc::impl::new \
        -contract_name "portal_datasource" -name $name \
        -pretty_name "" -owner $name

    # add the operations
    foreach {operation call} {
      GetMyName             "xowiki_admin_portlet name"
      GetPrettyName         "xowiki_admin_portlet pretty_name"
      Link                  "xowiki_admin_portlet link"
      AddSelfToPage         "xowiki_admin_portlet add_self_to_page"
      Show                  "xowiki_admin_portlet show"
      Edit                  "xowiki_admin_portlet edit"
      RemoveSelfFromPage    "xowiki_admin_portlet remove_self_from_page"
    } {
      acs_sc::impl::alias::new \
          -contract_name "portal_datasource" -impl_name $name \
          -operation $operation -alias $call \
          -language TCL
    }

    # Add the binding
    acs_sc::impl::binding::new \
        -contract_name "portal_datasource" -impl_name $name
  }
  :log "--portlet end of [self proc]"
}

xowiki_admin_portlet proc uninstall {} {
  :log "--portlet calling [self proc]"
  #
  # completely identical to "xowiki_portlet uninstall"
  #
  set name [:name]
  db_transaction {

    #
    # get the datasource
    #
    set ds_id [db_string dbqd..get_ds_id {
      select datasource_id from portal_datasources where name = :name
    } -default "0"]

    if {$ds_id != 0} {
      #
      # drop the datasource
      #
      portal::datasource::delete -name $name
      #
    } else {
      ns_log notice "No datasource id found for $name"
    }

    #
    #  drop the implementation
    #
    acs_sc::impl::delete \
        -contract_name "portal_datasource" -impl_name $name
  }
  :log "--portlet end of [self proc]"
}

# Local variables:
#    mode: tcl
#    tcl-indent-level: 2
#    indent-tabs-mode: nil
# End:
