TranslateApp::Application.routes.draw do

  get "feedbacks/vote"

  # TODO: comment these three in production mode
  resources :users
  #resources :dictionaries
  resources :annotations
  resources :articles

  # Old API, not used
  match '/settings', to: 'users#settings', via: :get
  # TODO change this url
  match '/validate_google_id_token', to: 'users#validate_google_id_token', via: [:get, :post]
  
  
  # annotation
  match '/create_annotation', to: 'annotations#create', via: [:get,:post]
  match '/delete_annotation', to: 'annotations#destroy', via: [:get, :post]
  match '/update_annotation', to: 'annotations#update_translation', via: [:get, :post]
  match '/show_annotation_by_user_url', to: 'annotations#show_by_user_url', via: [:get, :post]
  match '/show_annotation_by_url', to: 'annotations#show_by_url', via: [:get, :post]
  match '/show_annotation_count_by_url', to: 'annotations#show_count_by_url', via: [:get, :post]
  match '/show_user_annotation_history', to: 'annotations#show_user_annotation_history', via: [:get, :post]
  match '/show_user_annotations', to: 'annotations#show_user_annotations', via: [:get, :post]
  match '/show_user_annotated_urls', to: 'annotations#show_user_urls', via: [:get, :post]
  match '/show_most_annotated_urls', to: 'articles#show_most_annotated_urls', via: [:get, :post]

  # learn
  match '/show_learn_words', to: 'learnings#show_learn_words', via: :post
  match '/view', to: 'learnings#view', via: :post
  match '/take_quiz', to:'learnings#take_quiz', via: :post
  match '/show_user_learning_history', to: 'learnings#show_user_learning_history', via: :post
  match '/show_user_words', to: 'learnings#show_user_words', via: [:get, :post]

  # log
  match '/log', to: 'users#log', via: :post

  
  # feedback
  match '/vote', to: 'feedbacks#vote', via: [:get, :post]


  # test API
  match '/show_learn_words_demo', to: 'demos#show_learn_words', via: :post
  

  match '/create_new_user', to: 'users#create_new_user', via: :get

  # User Management
  match '/sign_up', to: 'users#sign_up_new_user', via: [:get,:post]
  match '/sign_up_complete', to: 'users#sign_up_complete', via: :get

  match '/login', to: 'sessions#new', via: :get
  match '/login', to: 'sessions#create', via: :post
  match '/login_complete', to: 'sessions#login_complete', via: :get
  match '/logout', to: 'sessions#logout', via: :get
  match '/request_password_reset', to: 'PasswordResets#request_password_reset', via: [:get,:post]
  match '/password_reset/:id', to: 'PasswordResets#reset_password', via: [:get,:post]

  match '/auth/:provider/callback', to: 'sessions#authenticate_social', via: :get
  match '/auth/failure', to: 'sessions#authenticate_social_failure', via: [:get, :post]

  match '/auth/facebook/most_annotate_share', to: 'facebook#share_most_annotated', via: :post
  


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
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

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
