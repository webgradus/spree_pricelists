require 'sidekiq'
module Spree
  class UpdateMissedProductsWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true

    def perform(pricelist_id, parsed_products)
        # TODO: need to optimize this things - it's slow
        Spree::Product.includes(:product_synonims).where(pricelist_id: pricelist_id).each do |product|
            unless parsed_products.any? { |parsed_product| product.product_synonims.pluck(:name).include?(parsed_product) }
                missed_product = product
                missed_product.update_attributes(price: 1, cost_price: 1, pricelist_id: nil)
                missed_product.update_stock_from_pricelist('quantity' => 0)
            end
        end
    end

  end
end
