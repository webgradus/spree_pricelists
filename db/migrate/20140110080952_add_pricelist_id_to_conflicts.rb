class AddPricelistIdToConflicts < ActiveRecord::Migration
  def change
    add_column :spree_conflicts, :pricelist_id, :integer, null: false
  end
end
