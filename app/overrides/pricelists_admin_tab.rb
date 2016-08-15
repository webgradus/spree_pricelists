Deface::Override.new(:virtual_path => "spree/layouts/admin",
                    :name => "pricelists_admin_tab",
                    :insert_bottom => "#main-sidebar",
                    :partial => 'spree/admin/shared/pricelists_sidebar_menu',
                    :disabled => false)
