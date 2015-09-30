require 'sidekiq'
module Spree
  class DataFactoryWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true, :retry => 5

    def perform(pricelist_id, taxonomy_id,taxon_id,attrs, product_properties, options)
      Spree::Importers::DataFactory.new(pricelist_id, taxonomy_id,taxon_id,attrs, product_properties, options).solve
    end

  end
end
