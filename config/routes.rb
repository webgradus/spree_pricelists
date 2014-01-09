Spree::Core::Engine.routes.draw do
  # Add your extension routes here
    namespace :admin do
      resources :pricelists do
        collection do
          get 'new_import'
          post "import"
        end
      end
      resources :conflicts, only: [:index, :update, :destroy]
    end
end
