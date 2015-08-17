class Spree::Importers::UpdateMasterQuantity

    attr_reader :log, :taxonomy, :taxon, :attrs, :pricelist

    def initialize(product_id, quantity)
      @product = Spree::Product.find(product_id)
      @quantity = quantity
      
    end

    def solve
      stock_location = Spree::StockLocation.active.first
      if stock_location
        # clear current quantity - reset to 0 before setting new quantity
        stock_location.unstock(@product.master, stock_location.count_on_hand(@product.master))
        stock_movement = stock_location.stock_movements.build(quantity: @quantity)
        stock_movement.stock_item = stock_location.set_up_stock_item(@product.master)
        stock_movement.stock_item.update_attributes(backorderable: false)
        stock_movement.save!
      end
 
    end
end
