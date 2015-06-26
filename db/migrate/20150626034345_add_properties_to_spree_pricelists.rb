class AddPropertiesToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :prop1, :integer
    add_column :spree_pricelists, :prop2, :integer
    add_column :spree_pricelists, :prop3, :integer
    add_column :spree_pricelists, :prop4, :integer
  end
end
