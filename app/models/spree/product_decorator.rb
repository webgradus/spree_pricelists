require 'pg_search'
Spree::Product.class_eval do
  include PgSearch

  has_many :product_synonims, class_name: 'Spree::ProductSynonim', dependent: :destroy

  after_create :add_synonim

  scope :find_by_synonim, lambda { |name| includes(:product_synonims).where("spree_product_synonims.name = ?", name).limit(1)}

  pg_search_scope :name_matching,
    associated_against: {product_synonims: :name},
    using: {
      trigram: {},
      tsearch: {dictionary: "russian", any_word: true}
    },
    ranked_by: "1.2 * :trigram + 0.5 * :tsearch"

  def add_synonim
    self.product_synonims.find_or_create_by_name(self.name)
  end
end
