class AddMarginToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :margin, :decimal, precision: 8, scale: 2
  end
end
