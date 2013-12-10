class CreateSpreeConflicts < ActiveRecord::Migration
  def change
    create_table :spree_conflicts do |t|
      t.string :product_name
      t.string :sku
      t.decimal :cost_price, precision: 10, scale: 2, null: false
      t.decimal :price, precision: 10, scale: 2, null: false
      t.string :provider_name

      t.timestamps
    end
  end
end
