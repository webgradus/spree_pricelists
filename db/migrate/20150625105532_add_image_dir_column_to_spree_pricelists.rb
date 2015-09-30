class AddImageDirColumnToSpreePricelists < ActiveRecord::Migration
  def change
    add_column :spree_pricelists, :image_dir_column, :string
  end
end
