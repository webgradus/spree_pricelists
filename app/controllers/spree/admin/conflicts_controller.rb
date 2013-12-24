module Spree
  module Admin
    class ConflictsController < BaseController
      def index
        @conflicts = Spree::Conflict.page(params[:page]).per(5)
      end

      def update
        @conflict = Spree::Conflict.find params[:id]
        @conflict.solve(params[:conflict])
      end
    end
  end
end
