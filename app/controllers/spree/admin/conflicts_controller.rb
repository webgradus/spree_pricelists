module Spree
  module Admin
    class ConflictsController < BaseController
      def index
        respond_to do |format|
          @conflicts = Spree::Conflict.page(params[:page]).per(5)
          unless request.xhr?
            format.html
          else
            format.js{ render 'index',:layout=>nil}
          end
        end
      end

      def update
        @conflict = Spree::Conflict.find params[:id]
        @conflict.solve(params[:conflict])
        redirect_to admin_conflicts_path
      end
    end
  end
end
