require 'sidekiq'
module Spree
  class DataFactoryWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true

    def perform(pricelist_id, taxonomy_id,taxon_id,attrs)
      Spree::Importers::DataFactory.new(pricelist_id, taxonomy_id,taxon_id,attrs).solve
    end

  end
end
