 module Spree
  module Admin
    class PricelistsController < BaseController
      def index
        @pricelists = Spree::Pricelist.all
      end

      def new
        @pricelist = Spree::Pricelist.new
      end

      def create
        @pricelist = Spree::Pricelist.new(pricelist_params)
        if @pricelist.save
          flash[:success] = flash_message_for(@pricelist, :successfully_created)
          redirect_to admin_pricelists_path
        else
          respond_with(@pricelist)
        end
      end

      def edit
        @pricelist = Spree::Pricelist.find(params[:id])
      end

      def update
        @pricelist = Spree::Pricelist.find(params[:id])

        if @pricelist.update_attributes(pricelist_params)
          flash[:success] = flash_message_for(@pricelist, :successfully_updated)
          redirect_to admin_pricelists_path
        else
          respond_with(@pricelist)
        end
      end

      def destroy
        @pricelist = Spree::Pricelist.find(params[:id])
        @pricelist.destroy
      end

      def import
        Spree::Importers::BaseImporter.parse(params[:pricelist], params[:xlsx_file],params[:starting_row])
        redirect_to admin_pricelists_path
      end

      protected

      def pricelist_params
        params.require(:pricelist).permit!
      end
    end
  end
end
