Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "pricelists_admin_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :partial => "spree/admin/shared/main_menu",
                     :disabled => false)
