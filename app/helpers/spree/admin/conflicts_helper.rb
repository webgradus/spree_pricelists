module Spree
  module Admin
    module ConflictsHelper
      def conflict_solve_actions
        [:create_new_product, :update_product].map do |action|
          [Spree.t(action), action]
        end
      end
    end
  end
end
