namespace :workspaces do

    desc "Populate latitude and longitude values"
    task :geocode => :environment do 
      include GeoKit::Geocoders

      ThinkingSphinx.updates_enabled = false

      Workspace.transaction do
        Workspace.all.each do |workspace|
          $stdout << "Adding lat/lng coordinates to #{workspace.name}..."
          location = workspace.location
          if location.lat.nil? or location.lng.nil?
              loc = MultiGeocoder.geocode(workspace.address)
              if loc.success
                begin
                  location.lat = loc.lat 
                  location.lng = loc.lng
                  location.save!
                  puts " done"
                rescue
                  puts " failed"
                end
              else
                puts " failed"
              end
          else
            puts " already present"
          end
        end
      end
    end

end
