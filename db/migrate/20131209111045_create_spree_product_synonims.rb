class CreateSpreeProductSynonims < ActiveRecord::Migration
  def change
    create_table :spree_product_synonims do |t|
      t.string :name
      t.references :product

      t.timestamps
    end
  end
end
