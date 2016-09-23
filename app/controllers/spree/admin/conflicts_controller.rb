module Spree
  module Admin
    class ConflictsController < ResourceController
      def index
        @conflicts = Spree::Conflict.order('created_at desc').page(params[:page]).per(5)
      end

      def update
        @conflict = Spree::Conflict.find params[:id]
        @conflict.solve(params[:conflict])
      end
    end
  end
end
