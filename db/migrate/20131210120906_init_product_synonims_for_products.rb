class InitProductSynonimsForProducts < ActiveRecord::Migration
  def up
    Spree::Product.find_each do |product|
      product.add_synonim
    end
  end

  def down
    Spree::ProductSynonim.destroy_all
  end
end
