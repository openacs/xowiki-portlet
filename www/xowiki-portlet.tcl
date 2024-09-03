array set config $cf
regsub {/[^/]+$} [ad_conn url] "/xowiki/$config(page_name)" url

# Local variables:
#    mode: tcl
#    tcl-indent-level: 4
#    indent-tabs-mode: nil
# End:
