namespace :db do
  namespace :integrity do

    desc "WARNING: Run all tasks"
    task :all => [
      :environment,
      "workspaces:set_root_as_owner", # ran in prod
    ]

    namespace :workspaces do
      
      desc "Set ROOT as owner of ALL imported workspaces"
      task :set_root_as_owner => :environment do
        Workspace.transaction do
          root = User.root
          Workspace.update_all("owner_id = #{root.id}")
        end
      end  # :set_root_as_owner

    end # workspaces

  end # :integrity
end # :db
