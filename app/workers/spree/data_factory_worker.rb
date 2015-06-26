require 'sidekiq'
module Spree
  class DataFactoryWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true

    def perform(pricelist_id, taxonomy_id,taxon_id,attrs, properties)
      Spree::Importers::DataFactory.new(pricelist_id, taxonomy_id,taxon_id,attrs, properties).solve
    end

  end
end
