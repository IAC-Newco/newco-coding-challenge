Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  namespace :api, defaults: { format: :json } do
    namespace :v1, defaults: { format: :json } do
      resources :feed, only: [] do
        collection do
          get 'ordered_by_creation'
          get 'for_user'
          get 'top'
          get 'custom'
        end
      end
    end
  end

end
