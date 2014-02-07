Deface::Override.new(:virtual_path => 'spree/admin/products/index',
  :name => 'add_pricelist_filter_to_admin_products',
  :insert_bottom => "[data-hook='admin_products_index_search']",
  :text => "
          <div class='alpha four columns'>
            <div class='field'>
                <%= f.label :pricelist_id_eq, Spree::Product.human_attribute_name(:pricelist) %>
                &nbsp;
                <%= f.collection_select :pricelist_id_eq, Spree::Pricelist.all, :id, :name, {include_blank: true}, class: 'select2' %>
            </div>
          </div>
  "
)
