# Must run before everthing else
# setup:root
# enumerations:reload
#
# After import
# rake ts:stop
# rake ts:in 
# rake ts:start
# rake workspaces:geocode

namespace :setup do
  
  desc "Create root user. PARAMS: PW=password"
  task :root => :environment do
    $stdout << "Creating root..."
    u = User.find_by_email_or_create(:email => 'root@propsify.com', 
                                     :name => 'propsroot', 
                                     :password => ENV['PW'],
                                     :password_confirmation => ENV['PW'])
    if u.valid?
      u.role = 'staff'
      u.save
      puts " done"
    else
      u.errors.each do |error|
        puts error 
      end
    end
  end

  task :user => :environment do
    $stdout << "Creating user..."
    u = User.find_by_email_or_create(:email    => ENV['EMAIL'], 
                                     :name     => ENV['NAME'], 
                                     :password => ENV['PW'],
                                     :password_confirmation => ENV['PW'])
    if u.valid?
      puts " done"
    else
      u.errors.each do |error|
        puts error 
      end
    end
  end


  namespace :workspaces do

    desc "Import workspaces from a CSV file"
    task :import => :environment do
      require 'csv'
   
      ThinkingSphinx.updates_enabled = false

      country = Country.find_by_name('Canada')
      count   = success = invalid_count = duplicate_count = failed_count = 0


      path = ENV['CSV']
      if path.blank?
        puts "requires CSV=path_to_file"
        return
      end

      User.transaction do
        CSV.open(path, 'r') do |row|
          count += 1 

          $stdout << "Adding #{row[0]} ..."
         
          user = User.root

          invalid = false
          invalid = true if row[0].blank?

          if row[6]
            subdivision = country.subdivisions.find_by_code(row[6].strip.upcase)
          else
            subdivision = nil
          end

          city = subdivision.nil? ? nil : subdivision.cities.find_by_name(row[5].strip)
          invalid = true if city.nil?

          if invalid
            puts " invalid"
            invalid_count += 1
            $stderr << CSV.generate_line(row) << ",invalid\n"
          elsif is_duplicate?(row[3], row[7])
            puts " duplicate"
            duplicate_count += 1
            $stderr << CSV.generate_line(row) << ",duplicate\n"
          else
            w = user.workspaces.new(
              :name => row[0], 
              :urls => row[1],
              :description => row[2],
              :contact_numbers => row[3],
              :location_attributes => {
                :country_id => country.id,
                :country_subdivision_id => subdivision.id,
                :city_id => city.id,
                :postal_code => row[7],
                :street_address => row[4]
              })
            begin
              w.save!
              success += 1
              puts " done"
              $stderr << CSV.generate_line(row) << ",ok\n"
            rescue
              puts " failed"
              failed_count += 1
              $stderr << CSV.generate_line(row) << ",failed\n"
            end
          end
        end

        puts "records:   #{count}"
        puts "success:   #{success}"
        puts "invalid:   #{invalid_count}"
        puts "failed:    #{failed_count}"
        puts "duplicate: #{duplicate_count}"
      end
    end # import


    def is_duplicate?(contact_numbers, postal_code) 
      dup = false
      Workspace.filter_by_postal_code(postal_code).each do |w|
        if w.contact_numbers == contact_numbers
          dup = true
          break
        end
      end
      return dup
    end

  end  # workspaces


  namespace :badges do 
    #convert base.jpg -gravity center -resize 160x -pointsize 400 -fill white  -annotate -40-200 '123' test.jpg

    desc "Create or update badges for all workspaces"
    task :update => :environment do
      # TODO: track last run, update only those that changed or only those updated within the past day
      # use size in filename

      size = "120x"
      params = {
        '120x' => {:pointsize => '50', :position => '0,-15'},
        '160x' => {:pointsize => '60', :position => '0,-20'},
      }

      dir  = File.join(Rails.root, 'public', 'system', 'badges')
      base = File.join(Rails.root, 'public', 'images', 'ratings', "badge-#{size}.jpg")
      bin  = '/usr/bin/convert'


      path_to_pid = File.join(Rails.root, 'tmp', 'pids', 'badge.task.pid')

      begin
        unless File.exist?(path_to_pid)
          File.open(path_to_pid, 'w') { |f| f.puts Process.pid }

          Workspace.find_each(:select => "id, votes_up", :batch_size => 100) do |workspace|
            puts "Updating workspace #{workspace.id}"
            file = File.join(dir, "#{workspace.id}-#{size}.jpg")
            text = workspace.votes_up
            cmd  = "#{bin} #{base} -gravity Center -fill white"
            cmd << " -pointsize #{params[size][:pointsize]}"
            cmd << " -draw \"text #{params[size][:position]} '#{text}'\" #{file}"
            system(cmd)
          end

          File.delete(path_to_pid) if File.exist?(path_to_pid)
        end
      rescue
        File.delete(path_to_pid) if File.exist?(path_to_pid)
        $stdout << "   task aborted\n"
      end

    end

  end # badges

end # setup
