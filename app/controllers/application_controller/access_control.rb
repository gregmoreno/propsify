class ApplicationController
  module AccessControl

    def self.included(app_controller)
      #app_controller.rescue_from 'Authorization::NotAuthorized', :with => :access_denied

      app_controller.before_filter :set_current_site
      app_controller.before_filter :set_current_user
      app_controller.before_filter :set_current_country
      app_controller.before_filter :set_current_city

      app_controller.helper_method :current_user
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session) && (not @current_user_session.nil?)
      @current_user_session = UserSession.find
    end

    def current_user
      return @current_user if defined?(@current_user) && (not @current_user.nil?)
      @current_user = current_user_session && current_user_session.user
    end

    def access_denied
      if current_user
        render 'errors/access_denied'
      else
        notify("The page you tried to access requires login")
        redirect_to(login_path)
      end
    end

    def require_user
      unless current_user
        store_location
        notify("The page you tried to access requires login")
        redirect_to(login_path)
        return false
      end
    end

    def authenticate_user(user)
      UserSession.create(user)
      set_current_user(user)
    end

    def logout_current_user
      if current_user
        store_location
        current_user_session.destroy
        redirect_back_or_default(root_url)
      end
    end

    def authorization_assert!(action, object)
      Authorization::Engine.instance.permit!(action, :object => object)
    end

    def store_location
      session[:return_to] = request.request_uri
    end

    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end

    def set_current_site
      Site.current = nil
      domain = request.host.split('.')[-2..-1].join('.')
      Site.current = Site.find_by_domain(domain.downcase)
    end

    def set_current_user(user = current_user)
      Authorization.current_user = user
    end

    def set_current_country
      # TODO: generic, config, case-INsensitive
      @current_country ||= Country.current = Country.find(:first, :conditions => ["LOWER(name) = ?", 'canada'])
    end

    def set_current_city
      # sans subdomain version
      if params[:city]
        # TODO: Should have parameterized version of cities for accurate matching
        City.current = Country.current.cities.find :first, :conditions => ["LOWER(cities.name) = ?", params[:city].titleize.downcase]
      else
        City.current = nil
      end
    end

    def logged_in?
      @logged_in ||= @current_user && @current_user.logged_in?
    end

  end
end
