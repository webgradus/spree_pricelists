class Spree::Pricelist < ActiveRecord::Base
  validates :name, presence: true, uniqueness: true
  validates :margin, presence: true
end
