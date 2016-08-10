Deface::Override.new(:virtual_path => "spree/layouts/admin",
                    :name => "pricelists_admin_tab",
                    :insert_bottom => "[data-hook='admin_tabs']",
                    :text => "
                              <ul class='nav nav-sidebar'>
                                <%= tab(:new_import, :url => new_import_admin_pricelists_path, :icon => 'file') %>
                              </ul>
                             ",
                    :disabled => false)
