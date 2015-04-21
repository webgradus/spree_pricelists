require 'sidekiq'
module Spree
  class ImportPricelistWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true

    def perform(pricelist_id, file_path, starting_row)
      pricelist = Spree::Pricelist.find(pricelist_id)
      # byebug
      Spree::Importers::BaseImporter.new(pricelist, file_path, starting_row).import
    end
  end
end
