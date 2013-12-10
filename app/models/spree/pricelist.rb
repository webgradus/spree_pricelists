class Spree::Pricelist < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
end
