require 'sidekiq'
module Spree
  class UpdateMasterQuantityWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true, :retry => 5

    def perform(product_id, quantity)
      Spree::Importers::UpdateMasterQuantity.new(product_id, quantity).solve
    end

  end
end
