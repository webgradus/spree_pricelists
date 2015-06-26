class AddDescColumnToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :desc_column, :integer
  end
end
