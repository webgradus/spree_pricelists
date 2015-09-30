Deface::Override.new(
  virtual_path: 'spree/layouts/admin',
  name: 'pricelists_admin_tab',
  insert_bottom: '#main-sidebar',
  partial: 'spree/admin/shared/pricelist_sidebar_menu'
)
