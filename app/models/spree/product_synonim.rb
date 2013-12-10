class Spree::ProductSynonim < ActiveRecord::Base

  validates :name, uniqueness: true

  belongs_to :product

  include PgSearch

  pg_search_scope :name_matching,
    against: :name ,
    using: {
      tsearch: {dictionary: "english", any_word: true,:tsvector_column => 'tsv_name'}
    },
    ranked_by: "1.2 * :trigram + 0.5 * :tsearch"

    def product
      Spree::Product.find_by_id(self.product_id)
    end

end
