class AddPropsToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :property1_label, :string
    add_column :spree_pricelists, :property2_label, :string
    add_column :spree_pricelists, :property3_label, :string
    add_column :spree_pricelists, :property4_label, :string
    add_column :spree_pricelists, :property5_label, :string
    add_column :spree_pricelists, :property6_label, :string
    add_column :spree_pricelists, :property1, :integer
    add_column :spree_pricelists, :property2, :integer
    add_column :spree_pricelists, :property3, :integer
    add_column :spree_pricelists, :property4, :integer
    add_column :spree_pricelists, :property5, :integer
    add_column :spree_pricelists, :property6, :integer
  end
end
