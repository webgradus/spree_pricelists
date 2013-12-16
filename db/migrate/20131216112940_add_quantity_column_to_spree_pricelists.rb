class AddQuantityColumnToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :quantity_column, :integer
  end
end
