Deface::Override.new(:virtual_path => "spree/layouts/admin",
                     :name => "pricelists_admin_tab",
                     :insert_bottom => "[data-hook='admin_tabs']",
                     :text => "<%= tab(:new_import, :url => new_import_admin_pricelists_path, :icon => 'icon-magic') %>",
                     :disabled => false)
