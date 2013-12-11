module Spree
  module Admin
    class ConflictsController < BaseController
      def index
        @conflicts = Spree::Conflict.page(params[:page]).per(5)
      end

      def update
        @conflict = Spree::Conflict.find params[:id]
        @conflict.solve(params[:conflict])
        redirect_to admin_conflicts_path
      end
    end
  end
end
