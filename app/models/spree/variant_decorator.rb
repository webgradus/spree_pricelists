Spree::Variant.class_eval do

  def update_stock_from_pricelist(attrs)
      stock_location = Spree::StockLocation.active.first
      if stock_location
          # if pricelist has quantity column, we update quantity
          # stock location should be backorderable: false by default
          # otherwise: we set products as backorderable
          if attrs['quantity'].present?
              # clear current quantity - reset to 0 before setting new quantity
              stock_location.unstock(self, stock_location.count_on_hand(self))
              stock_movement = stock_location.stock_movements.build(quantity: attrs['quantity'])
              stock_movement.stock_item = stock_location.set_up_stock_item(self)
              stock_movement.stock_item.update_attributes(backorderable: false)
              stock_movement.save!
          else
              stock_item = stock_location.stock_item_or_create(self)
              stock_item.update_attributes(backorderable: true)
          end
      end
  end

  private

    def set_master_out_of_stock
        if product.master && product.master.in_stock?
          product.master.stock_items.update_all(:backorderable => false)
          # product.master.stock_items.each { |item| item.reduce_count_on_hand_to_zero }
        end
      end
end
