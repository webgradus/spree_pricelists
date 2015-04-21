require 'pg_search'
Spree::Product.class_eval do
  include PgSearch

  has_many :product_synonims, class_name: 'Spree::ProductSynonim', dependent: :destroy
  belongs_to :pricelist

  before_update :update_synonim, if: lambda {|product| product.name_changed? }
  after_create :add_synonim

  scope :find_by_synonim, lambda { |name| joins(:product_synonims).where("spree_product_synonims.name = ?", name).limit(1)}

  pg_search_scope :name_matching,
    associated_against: {product_synonims: :name},
    using: {
      trigram: {},
      tsearch: {dictionary: "russian", any_word: true}
    },
    ranked_by: "1.2 * :trigram + 0.5 * :tsearch"

  def add_synonim(product_name=nil)
    self.product_synonims.find_or_create_by(:name => product_name || self.name)
  end

  def update_stock_from_pricelist(attrs)
      stock_location = Spree::StockLocation.active.first
      if stock_location
          # if pricelist has quantity column, we update quantity
          # stock location should be backorderable: false by default
          # otherwise: we set products as backorderable
          if attrs['quantity'].present?
              # clear current quantity - reset to 0 before setting new quantity
              stock_location.unstock(self.master, stock_location.count_on_hand(self.master))
              stock_movement = stock_location.stock_movements.build(quantity: attrs['quantity'])
              stock_movement.stock_item = stock_location.set_up_stock_item(self.master)
              stock_movement.stock_item.update_attributes(backorderable: false)
              stock_movement.save!
          else
              stock_item = stock_location.stock_item_or_create(self.master)
              stock_item.update_attributes(backorderable: true)
          end
      end
  end

  protected

  def update_synonim
    self.product_synonims.where(name: self.name_was).first.try(:update_attributes, {name: self.name})
  end
end
