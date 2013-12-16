require 'sidekiq'
module Spree
  class DataFactoryWorker
    include ::Sidekiq::Worker
    sidekiq_options :queue => :import, :backtrace => true

    def perform(taxonomy,taxon,attrs)
      Spree::Importers::DataFactory.new(taxonomy,taxon,attrs).solve
    end

  end
end
