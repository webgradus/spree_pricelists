module Spree
  module Admin
    class ProductSynonimsController < ResourceController
      belongs_to 'spree/product', :find_by => :slug
    end
  end
end
