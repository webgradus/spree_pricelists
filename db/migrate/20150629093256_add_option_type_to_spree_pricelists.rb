class AddOptionTypeToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :parent_column, :integer
    add_column :spree_pricelists, :otype1_label, :string
    add_column :spree_pricelists, :otype2_label, :string
    add_column :spree_pricelists, :otype3_label, :string
    add_column :spree_pricelists, :otype4_label, :string
    add_column :spree_pricelists, :otype1, :integer
    add_column :spree_pricelists, :otype2, :integer
    add_column :spree_pricelists, :otype3, :integer
    add_column :spree_pricelists, :otype4, :integer
  end
end
