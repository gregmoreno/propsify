# NOTE: This is replaced by friendly_id plugin
module ActionController
  class UrlRewriter
    private

    def rewrite_url_with_permalink(options)
      if options.delete(:permalink)
        case options[:use_route]
        when :workspace
          options.merge!(workspace_permalink(options[:id]))
        when :user 
          options.merge!(user_permalink(options[:id]))
        end
      end
          
      rewrite_url_without_permalink(options)
    end
    alias_method_chain :rewrite_url, :permalink


    def workspace_permalink(id)
      object =  id.is_a?(Fixnum) ? Workspace.find(id) : id 
      { :use_route => :workspace_permalink,
        :title     => object.name.parameterize,
        :city      => object.city.name.parameterize
      }
    end

    def user_permalink(id)
      object = id.is_a?(Fixnum) ? User.find(id) : id
      { :use_route => :user_permalink,
        :title      => object.profile ? object.profile.name.parameterize : object.name.parameterize
      }
    end
  end
end



