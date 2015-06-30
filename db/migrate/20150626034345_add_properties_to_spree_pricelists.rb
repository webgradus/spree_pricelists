class AddPropertiesToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :brand, :integer
    add_column :spree_pricelists, :skin, :integer
    add_column :spree_pricelists, :hair, :integer
    
  end
end
