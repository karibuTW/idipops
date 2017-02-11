require 'can_access_admin'

Rails.application.routes.draw do

  get '/feeds/simply-hired', to: 'feeds#simply_hired'
  get '/feeds/indeed-fr', to: 'feeds#indeed_fr'
  get '/feeds/wanajob', to: 'feeds#wanajob'
  get '/feeds/les-offres-emplois-fr', to: 'feeds#les_offres_emplois_fr'
  get '/feeds/trovit', to: 'feeds#trovit'

  root 'application#index'

  # constraints CanAccessAdmin do
    ResqueWeb::Engine.eager_load!
    mount ResqueWeb::Engine => "/resque"
  # end

  namespace :api do
    namespace :v1 do
      get '/users/is_email_free', to: 'users#check_email_is_free'
      post '/users/change_email', to: 'users#change_email'
      get '/users/request_password', to: 'users#request_password'
      put '/users/change_password', to: 'users#change_password'
      resources :users
      resources :professions
      resources :post_categories
      resources :places
      resources :classified_ads
      resources :professionals
      resources :tags
      get '/transactions/generate_invoice', to: 'transactions#generate_invoice'
      resources :transactions
      resources :quotation_requests
      resources :conversations
      resources :authorizations
      resources :deals
      resources :referrals do
        get :list, on: :collection
      end
      resources :sessions, only: [:create, :destroy]
      resources :pricings
      resources :quotation_request_templates
      resources :users_favorite_professionals, only: [:create, :destroy, :index]
      resources :users_favorite_posts, only: [:create, :destroy, :index]
      resources :users_favorite_post_comments, only: [:create, :destroy]
      resources :users_favorite_deals, only: [:create, :destroy, :index]
      resources :users_favorites, only: [:index]
      resources :pro_ratings
      resources :pro_reviews
      resources :profile_sponsorings
      resources :posts
      resources :post_category_subscriptions, only: [:create, :destroy]
      resources :post_author_subscriptions, only: [:create, :destroy]
      resources :post_comments, only: [:create, :index]
      get '/departements', to: 'places#departements'
      get '/user_notifications', to: 'users#get_notifications'
      get '/user_possible_nickname', to: 'users#get_possible_nickname'
    end
  end

  namespace :admin do
    get '/', to: 'dashboard#index'
    resources :users do
      member do
        post :add_credits
        post :subtract_credits
      end
    end
    resources :posts
    resources :professions
    resources :classified_ads
    resources :pricings
    resources :price_for_categories
    resources :deals
    resources :reviews
    resources :posts
    resources :post_comments
    resources :post_categories
  end

  resources :pros, path: '/pro', only: [:show]
  resources :posts, path: '/post', only: [:show]

  post '/payments/notify', to: 'payments#notify'
  get '/payments/cancel', to: 'payments#cancel'

  get '/images/:geometry' => Dragonfly.app.endpoint { |params, app|
    app.fetch(params[:uid]).thumb(params[:geometry])
  }

  get '/images/' => Dragonfly.app.endpoint { |params, app|
    app.fetch(params[:uid])
  }

  match "/websocket", to: WebsocketRails::ConnectionManager.new, via: [:get, :post]

  get "*path.html" => "application#index", :layout => 0
  get '*path' => 'application#index'
  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end
end
