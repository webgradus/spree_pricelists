class Spree::Conflict < ActiveRecord::Base
  belongs_to :pricelist
  validates :product_name, uniqueness: true

  def suitable_products
    Spree::ProductSynonim.name_matching(product_name).first(10)
  end

  def select_options_for_suitable_products
    options = {}
    suitable_products.each{|p| options[p.attributes["name"]] = p.attributes["product_id"]}
    options
  end

  def solve(attrs)
    action = attrs[:action]
    if action == "update_product"
      product = Spree::Product.find(attrs[:product])
      product.add_synonim(self.product_name)
      new_product_attrs = {}
      new_product_attrs[:price] = self.price.to_f if self.price.to_f > 0
      new_product_attrs[:cost_price] = self.cost_price.to_f if self.cost_price.to_f > 0
      new_product_attrs[:pricelist_id] = self.pricelist_id
      product.update_attributes(new_product_attrs)
      product.update_stock_from_pricelist(new_product_attrs.merge('quantity' => self.quantity))
    else
      product = Spree::Product.create!(name: self.product_name, sku: self.sku, price: self.price.to_f, cost_price: self.cost_price.to_f, pricelist_id: self.pricelist_id, shipping_category_id: Spree::ShippingCategory.first.id)
    end
    self.destroy
  end
end
