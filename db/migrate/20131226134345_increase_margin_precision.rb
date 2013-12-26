class IncreaseMarginPrecision < ActiveRecord::Migration
  def change
    change_column :spree_pricelists, :margin, :decimal, precision: 8, scale: 3
  end
end
