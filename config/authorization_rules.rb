authorization do
  role :member do
    has_permission_on :workspaces, :to => [:create]
    has_permission_on :workspaces, :to => [:list] do
      if_attribute :owner => is { user }
    end

    has_permission_on :votes, :to => [:read, :create]
    has_permission_on :votes, :to => [:update, :delete] do
      if_attribute :voter => is { user }
    end

    has_permission_on :invitations, :to => :update do
      if_attribute :created_for => is { user }
    end

    has_permission_on :users, :to => [ :start, :show, :update ] do
      if_attribute :id => is { user.id }
    end
    has_permission_on :users, :to => :new

    has_permission_on :twitter_accounts, :to => [ :authorize, :manage ] do
      if_permitted_to :update, :owner
    end
  end

  role :owner do
    includes :member

    has_permission_on :workspaces, :to => [:update, :delete, :read] do
      if_attribute :owner => is { user }
    end

    has_permission_on :votes, :to => :manage do
      if_attribute :voteable => { :owner => is { user } }
    end

    has_permission_on :invitations, :to => :manage do
      if_attribute :created_by => is { user }
    end
  end

  role :staff do
    has_permission_on [:workspaces, :invitations, :users, :votes], :to => [:manage] 
    has_permission_on :twitter_accounts, :to => [ :authorize, :manage ]

    # To view authorization setup publicly
    has_permission_on :authorization_rules, :to => :read
    has_permission_on :authorization_usages, :to => :read
  end

  role :guest do
    has_permission_on :users, :to => :create
  end
end

privileges do
  privilege :manage, :includes => [:create, :read, :update, :delete, :list]
  privilege :read,   :includes => [:index, :show]
  privilege :list,   :includes => :index
  privilege :create, :includes => :new
  privilege :update, :includes => :edit
  privilege :delete, :includes => :destroy
end
