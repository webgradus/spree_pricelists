require 'sidekiq'
module Spree
  class DataFactoryWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true

    def perform(pricelist_id, taxonomy_id,taxon_id,attrs, properties, options)
      Spree::Importers::DataFactory.new(pricelist_id, taxonomy_id,taxon_id,attrs, properties, options).solve
    end

  end
end
