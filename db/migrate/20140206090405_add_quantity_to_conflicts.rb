class AddQuantityToConflicts < ActiveRecord::Migration
  def change
    add_column :spree_conflicts, :quantity, :integer
  end
end
