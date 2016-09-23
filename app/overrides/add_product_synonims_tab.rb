Deface::Override.new(:virtual_path => 'spree/admin/shared/_product_tabs',
  :name => 'add_product_synonims_tab_to_products',
  :insert_bottom => "[data-hook='admin_product_tabs']",
  :text => "
      <%= content_tag :li, :class => ('active' if current == :product_synonims) do %>
        <%= link_to_with_icon 'clone', Spree.t(:product_synonims), admin_product_product_synonims_url(@product) %>
      <% end if can?(:admin, Spree::Product) %>
  "
)
