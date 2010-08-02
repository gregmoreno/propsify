ActionController::Routing::Routes.draw do |map|
  map.root                  :controller => 'search'
  map.logout   '/logout',   :controller => 'user_sessions', :action => 'destroy'
  map.login    '/login',    :controller => 'user_sessions', :action => 'new'
  map.register '/register', :controller => 'users', :action => 'create'
  map.signup   '/signup',   :controller => 'users', :action => 'new'
  map.start    '/start',    :controller => 'users', :action => 'start'
  map.confirm  '/confirm',  :controller => 'users', :action => 'confirm'

  map.resources :users, :as => 'u', :member => {:about => :get} do |user|
    user.resources :profiles
    user.resources :comments, :collection => {:manage => :get}
    user.resources :votes
  end

  map.resource :settings, :controller => 'users' do |settings|
    settings.resource :twitter_account, :name_prefix => nil, :member => { :authorize => :any },
      :path_names => { :edit => 'request_authorization' }
  end

  map.resources :workspaces, :as => 'b', :member => {:widget => :get} do |workspace|
    workspace.resources :invitations
    workspace.resources :comments
    workspace.resources :votes
    workspace.resource :twitter_account, :member => { :authorize => :any }, :path_names => { :edit => 'request_authorization' }
  end

  map.resources :comments, :collection => {:manage => :get}
  map.resources :profiles
  map.resources :locations
  map.resources :invitations, :member => {:resend => :post}
  map.resources :votes
  map.resource  :user_session
  map.resources :password_resets
  map.resource  :sitemap, :controller => 'sitemap'

  map.api '/api/b/:id.:format', :controller => 'workspaces', :action => 'show'

  map.accept_invitation '/invitations/accept/:token', :controller => 'invitations', :action => 'accept'

  map.search 's', :controller => 'search', :action => 'search'

  map.user_permalink      '/person/:title/:id', :controller => 'users', :action => 'show'
  map.workspace_permalink '/:city/:title/:id',  :controller => 'workspaces', :action => 'show'

  map.city  ':city', :controller => 'search', :action => 'city'

  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
