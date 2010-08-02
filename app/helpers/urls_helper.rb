module UrlsHelper

  def permalink(object)
    name = object.class.name.downcase 
    params = send("#{name}_permalink", object)
    send("#{name}_permalink_path", params) 
    #case object
    #when Workspace
    #  workspace_permalink_path(workspace_permalink(object))
    #end
  end

  private

  def workspace_permalink(id)
    workspace = id  # TODO: this could just be an ID. We assume object is passed
    {:title => "#{workspace.name.parameterize}",
     :id  => workspace.id, 
     :subdomain => workspace.city.name.parameterize
    }
  end

end
