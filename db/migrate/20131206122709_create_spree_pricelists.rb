class CreateSpreePricelists < ActiveRecord::Migration
  def change
    create_table :spree_pricelists do |t|
      t.string   :name
      t.integer  :sku_column
      t.integer  :name_column
      t.integer  :cost_price_column
      t.integer  :price_column

      t.timestamps
    end
  end
end
