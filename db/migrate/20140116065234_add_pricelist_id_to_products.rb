class AddPricelistIdToProducts < ActiveRecord::Migration
  def change
    add_column :spree_products, :pricelist_id, :integer
  end
end
